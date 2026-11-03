--- Build-tool providers.
---
--- A tool provider is only considered when one of its marker files is present
--- in the project root (`vim.fn.getcwd()`).  Tools with a higher `priority`
--- win when several markers exist at once (for example `Cargo.toml` wins over
--- a generic `Makefile`).
local M = {}

local util = require("custom.project_runner.util")
local languages = require("custom.project_runner.providers.languages")

--------------------------------------------------------------------------------
-- Generic helpers
--------------------------------------------------------------------------------

--- Build a shell snippet that runs the first executable found.
---
--- The search order is:
---   1. `<root>/.build/<project-name>`
---   2. common build-tool output paths
---   3. caller supplied candidates
---   4. the first executable found below the search directories
---
--- When the discovered binary is not already `<root>/.build/<project-name>`,
--- a symlink is created there so the plugin's executable name contract holds.
--- @param ctx table
--- @param opts table|nil
--- @return string
function M.artifact_run(ctx, opts)
	opts = opts or {}
	local build_dir = ctx.build_dir
	local name = ctx.name
	local is_windows = util.is_windows()

	if is_windows then
		local lines = { 'set "bin="' }
		local seen = {}
		local function consider(path)
			if not path or seen[path] then
				return
			end
			seen[path] = true
			lines[#lines + 1] = 'if not defined bin if exist "' .. path .. '" set "bin=' .. path .. '"'
		end

		consider(ctx.exe)
		consider(util.join(build_dir, "bin", name .. ".exe"))
		consider(util.join(build_dir, "release", name .. ".exe"))
		consider(util.join(build_dir, "debug", name .. ".exe"))
		for _, path in ipairs(opts.candidates or {}) do
			consider(path)
		end

		lines[#lines + 1] = 'if not defined bin (echo project_runner: no executable found in "'
			.. build_dir
			.. '" 1>&2 & exit /b 127)'
		lines[#lines + 1] = '"%bin%"'
		return table.concat(lines, " & ")
	end

	local lines = { 'bin=""' }
	local seen = {}
	local function consider(path)
		if not path or seen[path] then
			return
		end
		seen[path] = true
		lines[#lines + 1] = '[ -z "$bin" ] && [ -x ' .. util.q(path) .. " ] && bin=" .. util.q(path)
	end

	consider(ctx.exe)
	consider(util.join(build_dir, "bin", name))
	consider(util.join(build_dir, "release", name))
	consider(util.join(build_dir, "debug", name))
	for _, path in ipairs(opts.candidates or {}) do
		consider(path)
	end

	local depth = opts.max_depth and (" -maxdepth " .. tostring(opts.max_depth)) or ""
	for _, directory in ipairs(opts.search_dirs or { build_dir }) do
		lines[#lines + 1] = '[ -n "$bin" ] || bin="$(find '
			.. util.q(directory)
			.. depth
			.. ' -type f -perm -111 ! -name "*.so" ! -name "*.dylib" ! -name "*.a"'
			.. ' ! -path "*/CMakeFiles/*" 2>/dev/null | head -n 1)"'
	end

	lines[#lines + 1] = '[ -n "$bin" ] && [ "$bin" != '
		.. util.q(ctx.exe)
		.. ' ] && { ln -sf "$bin" '
		.. util.q(ctx.exe)
		.. ' 2>/dev/null || cp "$bin" '
		.. util.q(ctx.exe)
		.. "; bin="
		.. util.q(ctx.exe)
		.. "; }"
	lines[#lines + 1] = '[ -n "$bin" ] || { echo '
		.. util.q("project_runner: no executable found in " .. build_dir)
		.. " >&2; exit 127; }"
	lines[#lines + 1] = 'exec "$bin"'
	return table.concat(lines, "; ")
end

--- Build a shell snippet that runs `dotnet <dll>`.
--- @param ctx table
--- @return string
local function dotnet_run(ctx)
	local lines = {
		"dll=" .. util.q(util.join(ctx.build_dir, ctx.name .. ".dll")),
		'[ -f "$dll" ] || dll="$(find '
			.. util.q(ctx.build_dir)
			.. ' -maxdepth 1 -type f -name "*.dll" ! -name "*.resources.dll" 2>/dev/null | head -n 1)"',
		'[ -n "$dll" ] || { echo '
			.. util.q("project_runner: no .dll found in " .. ctx.build_dir)
			.. " >&2; exit 127; }",
		'exec dotnet "$dll"',
	}
	return table.concat(lines, "; ")
end

--- Copy the first jar found in `source_dir` to `.build/<project>.jar`.
--- @param source_dir string
--- @param destination string
--- @return string
local function copy_jar_command(source_dir, destination)
	return "mkdir -p "
		.. util.q(util.dirname(destination))
		.. " && jar=$(find "
		.. util.q(source_dir)
		.. ' -maxdepth 1 -type f -name "*.jar" ! -name "*-sources.jar" ! -name "*-javadoc.jar" | head -n 1)'
		.. ' && [ -n "$jar" ] && cp "$jar" '
		.. util.q(destination)
end

--- Read package.json, returning nil on malformed JSON.
--- @param root string
--- @return table|nil
local function read_package_json(root)
	local content = util.read_file(util.join(root, "package.json"))
	if not content then
		return nil
	end
	local ok, decoded = pcall(vim.json.decode, content)
	if ok and type(decoded) == "table" then
		return decoded
	end
	return nil
end

--- Detect the package manager used by a JavaScript project.
--- @param root string
--- @return string
local function node_package_manager(root)
	if util.exists(util.join(root, "bun.lockb")) or util.exists(util.join(root, "bun.lock")) then
		return "bun"
	end
	if util.exists(util.join(root, "pnpm-lock.yaml")) then
		return "pnpm"
	end
	if util.exists(util.join(root, "yarn.lock")) then
		return "yarn"
	end
	if util.exists(util.join(root, "package-lock.json")) then
		return "npm"
	end
	return util.first_executable("bun", "pnpm", "yarn", "npm") or "npm"
end

--- Run a JavaScript/TypeScript file with the best available runtime.
--- @param entry string
--- @param root string
--- @return string
local function node_file_command(entry, root)
	local extension = util.extension(entry)
	if extension == "ts" or extension == "mts" or extension == "cts" or extension == "tsx" then
		return languages.typescript_command(entry)
	end
	return languages.javascript_command(entry, root)
end

--- Find the executable name declared by a Haskell package.
--- @param root string
--- @param fallback string
--- @return string
local function haskell_executable(root, fallback)
	for _, cabal in ipairs(util.glob(root, "*.cabal")) do
		local content = util.read_file(cabal) or ""
		local executable = content:match("executable%s+([%w%-_]+)")
		if executable then
			return executable
		end
	end
	return fallback
end

--------------------------------------------------------------------------------
-- Tool definitions
--------------------------------------------------------------------------------

local tools = {
	{
		id = "cargo",
		label = "Cargo",
		priority = 100,
		markers = { "Cargo.toml" },
		language = "rust",
		kind = "compiled",
		plan = function(ctx)
			return {
				build = "CARGO_TARGET_DIR=" .. util.q(ctx.build_dir) .. " cargo build --release",
				run = M.artifact_run(ctx, {
					candidates = {
						util.join(ctx.build_dir, "release", ctx.name),
						util.join(ctx.build_dir, "release", ctx.name .. ".exe"),
					},
					search_dirs = { util.join(ctx.build_dir, "release") },
				}),
			}
		end,
	},

	{
		id = "cmake",
		label = "CMake",
		priority = 95,
		markers = { "CMakeLists.txt" },
		kind = "compiled",
		plan = function(ctx)
			local build = "cmake -S . -B "
				.. util.q(ctx.build_dir)
				.. " -DCMAKE_BUILD_TYPE=Release -DCMAKE_RUNTIME_OUTPUT_DIRECTORY="
				.. util.q(util.join(ctx.build_dir, "bin"))
				.. " && cmake --build "
				.. util.q(ctx.build_dir)
				.. " --parallel --config Release"
			return {
				build = build,
				run = M.artifact_run(ctx, {
					candidates = { util.join(ctx.build_dir, "bin", ctx.name) },
					search_dirs = { util.join(ctx.build_dir, "bin"), ctx.build_dir },
				}),
			}
		end,
	},

	{
		id = "zig",
		label = "Zig build",
		priority = 92,
		markers = { "build.zig" },
		kind = "compiled",
		plan = function(ctx)
			return {
				build = "zig build --prefix " .. util.q(ctx.build_dir) .. " -Doptimize=ReleaseFast",
				run = M.artifact_run(ctx, {
					candidates = { util.join(ctx.build_dir, "bin", ctx.name) },
					search_dirs = { util.join(ctx.build_dir, "bin"), ctx.build_dir },
				}),
			}
		end,
	},

	{
		id = "swift",
		label = "Swift Package",
		priority = 90,
		markers = { "Package.swift" },
		kind = "compiled",
		plan = function(ctx)
			return {
				build = "swift build -c release --scratch-path " .. util.q(ctx.build_dir),
				run = M.artifact_run(ctx, {
					candidates = { util.join(ctx.build_dir, "release", ctx.name) },
					search_dirs = { util.join(ctx.build_dir, "release") },
				}),
			}
		end,
	},

	{
		id = "go",
		label = "Go modules",
		priority = 89,
		markers = { "go.mod" },
		language = "go",
		kind = "compiled",
		plan = function(ctx)
			local package = "."
			if ctx.entry then
				local relative = util.relative(ctx.root, util.dirname(ctx.entry)):gsub("\\", "/")
				if relative ~= "." then
					package = "./" .. relative
				end
			end
			return {
				build = "mkdir -p " .. util.q(ctx.build_dir) .. " && go build -o " .. util.q(ctx.exe) .. " " .. util.q(
					package
				),
				run = util.q(ctx.exe),
			}
		end,
	},

	{
		id = "meson",
		label = "Meson",
		priority = 85,
		markers = { "meson.build" },
		kind = "compiled",
		plan = function(ctx)
			local build = "( [ -d "
				.. util.q(ctx.build_dir)
				.. " ] || meson setup "
				.. util.q(ctx.build_dir)
				.. " --buildtype=release ) && meson compile -C "
				.. util.q(ctx.build_dir)
			return {
				build = build,
				run = M.artifact_run(ctx, {
					search_dirs = { ctx.build_dir, util.join(ctx.build_dir, "bin") },
				}),
			}
		end,
	},

	{
		id = "node",
		label = "Node / package.json",
		priority = 80,
		markers = { "package.json" },
		kind = "interpreted",
		plan = function(ctx)
			local root = ctx.root
			local package = read_package_json(root) or {}
			local scripts = package.scripts or {}
			local manager = node_package_manager(root)
			local entry = ctx.entry
				or languages.entrypoint("javascript", root)
				or languages.entrypoint("typescript", root)
				or (package.main and util.join(root, package.main))

			if scripts.start then
				return { run = manager .. " run start", entry = entry }
			end
			if scripts.dev then
				return { run = manager .. " run dev", entry = entry }
			end
			if scripts.serve then
				return { run = manager .. " run serve", entry = entry }
			end
			if scripts.build and scripts.preview then
				return {
					build = manager .. " run build",
					run = manager .. " run preview",
					entry = entry,
				}
			end
			if scripts.build and entry then
				return {
					build = manager .. " run build",
					run = node_file_command(entry, root),
					entry = entry,
				}
			end
			if entry then
				return { run = node_file_command(entry, root), entry = entry }
			end
			return nil
		end,
	},

	{
		id = "deno",
		label = "Deno",
		priority = 78,
		markers = { "deno.json", "deno.jsonc" },
		kind = "interpreted",
		plan = function(ctx)
			local content = util.read_file(util.join(ctx.root, "deno.json"))
				or util.read_file(util.join(ctx.root, "deno.jsonc"))
				or ""
			local entry = languages.entrypoint("typescript", ctx.root) or languages.entrypoint("javascript", ctx.root)
			if content:find('"start"%s*:') then
				return { run = "deno task start", entry = entry }
			end
			if entry then
				return { run = "deno run -A " .. util.q(entry), entry = entry }
			end
			return nil
		end,
	},

	{
		id = "maven",
		label = "Maven",
		priority = 74,
		markers = { "pom.xml" },
		kind = "compiled",
		plan = function(ctx)
			local maven = util.is_file(util.join(ctx.root, "mvnw")) and "./mvnw"
				or (util.first_executable("mvn") or nil)
			if not maven then
				return nil
			end

			local jar = util.join(ctx.build_dir, ctx.name .. ".jar")
			return {
				build = maven .. " -q -DskipTests package && " .. copy_jar_command(util.join(ctx.root, "target"), jar),
				run = "java -jar " .. util.q(jar),
			}
		end,
	},

	{
		id = "gradle",
		label = "Gradle",
		priority = 73,
		markers = {
			"build.gradle",
			"build.gradle.kts",
			"settings.gradle",
			"settings.gradle.kts",
			"gradlew",
		},
		kind = "compiled",
		plan = function(ctx)
			local gradle
			if util.is_file(util.join(ctx.root, "gradlew")) then
				gradle = "./gradlew"
			elseif util.which("gradle") then
				gradle = "gradle"
			else
				return nil
			end

			local jar = util.join(ctx.build_dir, ctx.name .. ".jar")
			return {
				build = gradle .. " build -x test && " .. copy_jar_command(util.join(ctx.root, "build", "libs"), jar),
				run = "java -jar " .. util.q(jar),
			}
		end,
	},

	{
		id = "dotnet",
		label = ".NET",
		priority = 72,
		patterns = { "*.sln", "*.csproj", "*.fsproj", "*.vbproj" },
		kind = "compiled",
		plan = function(ctx)
			return {
				build = "dotnet build -c Release -o " .. util.q(ctx.build_dir),
				run = dotnet_run(ctx),
			}
		end,
	},

	{
		id = "elixir",
		label = "Mix",
		priority = 70,
		markers = { "mix.exs" },
		kind = "compiled",
		plan = function(ctx)
			-- Mix stores build artifacts under `_build`; `MIX_BUILD_PATH`
			-- redirects that whole tree into the project's `.build` directory.
			local env = "MIX_BUILD_PATH=" .. util.q(ctx.build_dir)
			return {
				build = env .. " mix compile",
				run = env .. " mix run",
			}
		end,
	},

	{
		id = "stack",
		label = "Stack",
		priority = 68,
		markers = { "stack.yaml", "stack.yml" },
		language = "haskell",
		kind = "compiled",
		plan = function(ctx)
			-- Stack exposes a global `--work-dir` option; placing it before the
			-- subcommand applies it to both `build` and `exec`.
			local work_dir = " --work-dir " .. util.q(ctx.build_dir)
			return {
				build = "stack" .. work_dir .. " build",
				run = "stack" .. work_dir .. " exec " .. util.q(haskell_executable(ctx.root, ctx.name)),
			}
		end,
	},

	{
		id = "cabal",
		label = "Cabal",
		priority = 67,
		patterns = { "*.cabal", "cabal.project" },
		language = "haskell",
		kind = "compiled",
		plan = function(ctx)
			-- `--builddir` moves Cabal's dist-newstyle tree under `.build`.
			local build_dir = " --builddir=" .. util.q(ctx.build_dir)
			return {
				build = "cabal build" .. build_dir,
				run = "cabal run" .. build_dir .. " " .. util.q(haskell_executable(ctx.root, ctx.name)),
			}
		end,
	},

	{
		id = "dune",
		label = "Dune",
		priority = 66,
		markers = { "dune-project", "dune-workspace" },
		kind = "compiled",
		plan = function(ctx)
			-- Dune's build tree defaults to `_build`; `--build-dir` relocates it
			-- while `exec` reads from the same directory.
			local build_dir = " --build-dir=" .. util.q(ctx.build_dir)
			return {
				build = "dune build" .. build_dir,
				run = "dune exec" .. build_dir .. " " .. util.q(ctx.name),
			}
		end,
	},

	{
		id = "gleam",
		label = "Gleam",
		priority = 65,
		markers = { "gleam.toml" },
		kind = "compiled",
		plan = function()
			return {
				build = "gleam build",
				run = "gleam run",
			}
		end,
	},

	{
		id = "dart",
		label = "Dart / Flutter",
		priority = 64,
		markers = { "pubspec.yaml" },
		language = "dart",
		kind = "interpreted",
		plan = function(ctx)
			local content = util.read_file(util.join(ctx.root, "pubspec.yaml")) or ""
			if content:find("sdk:%s*flutter") or content:match("^%s*flutter%s*:") then
				return { run = "flutter run" }
			end
			local entry = ctx.entry or languages.entrypoint("dart", ctx.root)
			if entry then
				return { run = "dart run " .. util.q(entry), entry = entry }
			end
			return nil
		end,
	},

	{
		id = "shard",
		label = "Shards",
		priority = 63,
		markers = { "shard.yml" },
		language = "crystal",
		kind = "compiled",
		plan = function(ctx)
			local content = util.read_file(util.join(ctx.root, "shard.yml")) or ""
			local name = content:match("^name:%s*([%w%-_]+)") or ctx.name
			return {
				build = "shards build --release",
				run = M.artifact_run(ctx, {
					candidates = { util.join(ctx.root, "bin", name) },
					search_dirs = { util.join(ctx.root, "bin") },
				}),
			}
		end,
	},

	{
		id = "sbt",
		label = "sbt",
		priority = 62,
		markers = { "build.sbt" },
		kind = "compiled",
		plan = function()
			return {
				build = "sbt compile",
				run = "sbt run",
			}
		end,
	},

	{
		id = "python",
		label = "Python project",
		priority = 55,
		markers = {
			"pyproject.toml",
			"setup.py",
			"requirements.txt",
			"Pipfile",
			"uv.lock",
			"poetry.lock",
			"pdm.lock",
		},
		language = "python",
		kind = "interpreted",
		plan = function(ctx)
			if not ctx.entry then
				return nil
			end

			local root = ctx.root
			local command
			if util.exists(util.join(root, "uv.lock")) and util.which("uv") then
				command = "uv run python " .. util.q(ctx.entry)
			elseif util.exists(util.join(root, "poetry.lock")) and util.which("poetry") then
				command = "poetry run python " .. util.q(ctx.entry)
			elseif util.exists(util.join(root, "Pipfile")) and util.which("pipenv") then
				command = "pipenv run python " .. util.q(ctx.entry)
			else
				command = languages.python_command(root) .. " " .. util.q(ctx.entry)
			end

			return { run = command }
		end,
	},

	{
		id = "julia",
		label = "Julia project",
		priority = 54,
		markers = { "Project.toml" },
		language = "julia",
		kind = "interpreted",
		plan = function(ctx)
			if not ctx.entry then
				return nil
			end
			return { run = "julia --project=. " .. util.q(ctx.entry) }
		end,
	},

	{
		id = "r",
		label = "R package",
		priority = 53,
		markers = { "DESCRIPTION" },
		language = "r",
		kind = "interpreted",
		plan = function(ctx)
			if not ctx.entry then
				return nil
			end
			return { run = "Rscript " .. util.q(ctx.entry) }
		end,
	},

	{
		id = "ruby",
		label = "Ruby / Bundler",
		priority = 52,
		markers = { "Gemfile", "Rakefile", "config.ru" },
		language = "ruby",
		kind = "interpreted",
		plan = function(ctx)
			local root = ctx.root
			local command
			if ctx.entry then
				command = (languages.ruby_command(root) or "ruby") .. " " .. util.q(ctx.entry)
			elseif util.is_file(util.join(root, "config.ru")) then
				command = util.which("bundle") and "bundle exec rackup config.ru" or "rackup config.ru"
			elseif util.is_file(util.join(root, "Rakefile")) then
				command = util.which("bundle") and "bundle exec rake" or "rake"
			end
			if not command then
				return nil
			end
			return { run = command }
		end,
	},

	{
		id = "lua",
		label = "Lua rockspec",
		priority = 45,
		patterns = { "*.rockspec" },
		language = "lua",
		kind = "interpreted",
		plan = function(ctx)
			if not ctx.entry then
				return nil
			end
			local lua = util.first_executable("lua", "luajit") or "lua"
			return { run = lua .. " " .. util.q(ctx.entry) }
		end,
	},

	{
		id = "make",
		label = "Make",
		priority = 10,
		markers = { "Makefile", "makefile", "GNUmakefile" },
		kind = "compiled",
		plan = function(ctx)
			local makefile = util.join(ctx.root, "Makefile")
			if not util.is_file(makefile) then
				makefile = util.join(ctx.root, "makefile")
			end
			if not util.is_file(makefile) then
				makefile = util.join(ctx.root, "GNUmakefile")
			end

			local content = util.read_file(makefile) or ""
			local has_run_target = content:match("[\n]run%s*:") or content:match("^run%s*:")
			local make = util.first_executable("gmake", "make") or "make"

			return {
				build = make .. " -j",
				run = has_run_target and (make .. " run") or M.artifact_run(ctx, {
					candidates = {
						util.join(ctx.root, ctx.name),
						util.join(ctx.root, "bin", ctx.name),
					},
					search_dirs = { ctx.build_dir, ctx.root },
					max_depth = 2,
				}),
			}
		end,
	},
}

--------------------------------------------------------------------------------
-- Detection
--------------------------------------------------------------------------------

M.list = tools

--- Return the marker that identifies `tool` in `root`, or nil.
--- @param tool table
--- @param root string
--- @return string|nil
function M.detect(tool, root)
	for _, marker in ipairs(tool.markers or {}) do
		if util.exists(util.join(root, marker)) then
			return marker
		end
	end

	for _, pattern in ipairs(tool.patterns or {}) do
		local matches = util.glob(root, pattern)
		if #matches > 0 then
			return util.basename(matches[1])
		end
	end

	return nil
end

return M
