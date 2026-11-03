--- Language providers used when a project has no recognised build tool.
---
--- A provider knows:
---   * which file extensions / filetypes belong to the language,
---   * where the entry point normally lives,
---   * how to build it (compiled languages only), and
---   * how to run it.
---
--- Compiled providers always place their artifact in `<root>/.build/` and use
--- the root directory name as the executable name.
local M = {}

local util = require("custom.project_runner.util")
local config = require("custom.project_runner.config")

local DEFAULT_STEMS = { "main", "index", "app", "run", "start", "server", "init" }

--------------------------------------------------------------------------------
-- Search helpers
--------------------------------------------------------------------------------

--- @return string[]
local function ignored_dirs()
	return config.get().ignored_dirs
end

--- Check explicit relative candidates in priority order.
--- @param root string
--- @param candidates string[]
--- @return string|nil
local function candidate_paths(root, candidates)
	for _, relative in ipairs(candidates or {}) do
		local path = util.join(root, relative)
		if util.is_file(path) then
			return util.abspath(path)
		end
	end
	return nil
end

--- Find files whose stem is one of `stems` and extension one of `extensions`.
--- @param root string
--- @param extensions string[]
--- @param stems string[]|nil
--- @return string[]
local function files_from_stems(root, extensions, stems)
	local paths = {}
	for _, stem in ipairs(stems or DEFAULT_STEMS) do
		for _, extension in ipairs(extensions) do
			vim.list_extend(paths, util.glob(root, "**/" .. stem .. "." .. extension))
		end
	end
	return util.clean_paths(paths, root, ignored_dirs())
end

--- Return the shallowest file containing a Lua pattern.
--- @param root string
--- @param extensions string[]
--- @param pattern string
--- @return string|nil
local function files_containing(root, extensions, pattern)
	local files = util.clean_paths(util.files_with_extensions(root, extensions), root, ignored_dirs())
	for _, path in ipairs(files) do
		local content = util.read_file(path)
		if content and content:find(pattern) then
			return path
		end
	end
	return nil
end

--- Source files used by direct compiler commands.
--- @param ctx table
--- @param extensions string[]
--- @return string[]
local function source_files(ctx, extensions)
	local files = util.clean_paths(util.files_with_extensions(ctx.root, extensions), ctx.root, ignored_dirs())
	if #files == 0 then
		files = { ctx.entry }
	end
	return files
end

--- Extra compiler arguments configured for a language.
--- @param id string
--- @return string
local function extra_args(id)
	local args = config.get().build_args or {}
	return args[id] or ""
end

--------------------------------------------------------------------------------
-- Interpreter helpers
--------------------------------------------------------------------------------

--- @param root string
--- @return string
local function python_command(root)
	local candidates = {
		".venv/bin/python",
		".venv/bin/python3",
		"venv/bin/python",
		"venv/bin/python3",
		"env/bin/python",
		"Scripts/python.exe",
	}

	for _, relative in ipairs(candidates) do
		local path = util.join(root, relative)
		if util.is_file(path) then
			return util.q(path)
		end
	end

	return util.first_executable("python3", "python") or "python3"
end

--- @param root string
--- @return string|nil
local function ruby_command(root)
	if util.is_file(util.join(root, "Gemfile")) and util.which("bundle") then
		return "bundle exec ruby"
	end
	return util.first_executable("ruby")
end

--- @param entry string
--- @param root string
--- @return string
local function javascript_command(entry, root)
	local bun = util.first_executable("bun")
	if bun then
		return bun .. " run " .. util.q(entry)
	end

	local deno = util.first_executable("deno")
	if deno then
		return deno .. " run -A " .. util.q(entry)
	end

	local node = util.first_executable("node", "nodejs") or "node"
	local _ = root
	return node .. " " .. util.q(entry)
end

--- @param entry string
--- @return string
local function typescript_command(entry)
	local bun = util.first_executable("bun")
	if bun then
		return bun .. " run " .. util.q(entry)
	end

	local deno = util.first_executable("deno")
	if deno then
		return deno .. " run -A " .. util.q(entry)
	end

	local tsx = util.first_executable("tsx")
	if tsx then
		return tsx .. " " .. util.q(entry)
	end

	local ts_node = util.first_executable("ts-node")
	if ts_node then
		return ts_node .. " " .. util.q(entry)
	end

	return "npx --yes tsx " .. util.q(entry)
end

--------------------------------------------------------------------------------
-- Language definitions
--------------------------------------------------------------------------------

local languages = {
	{
		id = "python",
		label = "Python",
		kind = "interpreted",
		extensions = { "py", "pyw" },
		filetypes = { "python" },
		entrypoints = {
			"main.py",
			"app.py",
			"__main__.py",
			"run.py",
			"server.py",
			"manage.py",
			"src/main.py",
			"src/app.py",
		},
		run = function(ctx)
			return python_command(ctx.root) .. " " .. util.q(ctx.entry)
		end,
	},

	{
		id = "javascript",
		label = "JavaScript",
		kind = "interpreted",
		extensions = { "js", "mjs", "cjs", "jsx" },
		filetypes = { "javascript", "javascriptreact" },
		entrypoints = {
			"index.js",
			"main.js",
			"app.js",
			"server.js",
			"src/index.js",
			"src/main.js",
			"src/app.js",
			"server/index.js",
		},
		run = function(ctx)
			return javascript_command(ctx.entry, ctx.root)
		end,
	},

	{
		id = "typescript",
		label = "TypeScript",
		kind = "interpreted",
		extensions = { "ts", "mts", "cts", "tsx" },
		filetypes = { "typescript", "typescriptreact" },
		entrypoints = {
			"index.ts",
			"main.ts",
			"app.ts",
			"server.ts",
			"src/index.ts",
			"src/main.ts",
			"src/app.ts",
			"src/server.ts",
		},
		run = function(ctx)
			return typescript_command(ctx.entry)
		end,
	},

	{
		id = "lua",
		label = "Lua",
		kind = "interpreted",
		extensions = { "lua" },
		filetypes = { "lua" },
		entrypoints = { "init.lua", "main.lua", "src/init.lua", "src/main.lua" },
		run = function(ctx)
			local lua = util.first_executable("lua", "luajit") or "lua"
			return lua .. " " .. util.q(ctx.entry)
		end,
	},

	{
		id = "ruby",
		label = "Ruby",
		kind = "interpreted",
		extensions = { "rb" },
		filetypes = { "ruby" },
		entrypoints = { "main.rb", "app.rb", "config.ru", "src/main.rb", "bin/main" },
		run = function(ctx)
			local ruby = ruby_command(ctx.root) or "ruby"
			return ruby .. " " .. util.q(ctx.entry)
		end,
	},

	{
		id = "php",
		label = "PHP",
		kind = "interpreted",
		extensions = { "php" },
		filetypes = { "php" },
		entrypoints = { "index.php", "main.php", "public/index.php", "src/index.php" },
		run = function(ctx)
			return "php " .. util.q(ctx.entry)
		end,
	},

	{
		id = "perl",
		label = "Perl",
		kind = "interpreted",
		extensions = { "pl", "pm" },
		filetypes = { "perl" },
		entrypoints = { "main.pl", "app.pl", "script/main.pl" },
		run = function(ctx)
			return "perl " .. util.q(ctx.entry)
		end,
	},

	{
		id = "r",
		label = "R",
		kind = "interpreted",
		extensions = { "r", "R" },
		filetypes = { "r" },
		entrypoints = { "main.R", "app.R", "src/main.R" },
		run = function(ctx)
			return "Rscript " .. util.q(ctx.entry)
		end,
	},

	{
		id = "julia",
		label = "Julia",
		kind = "interpreted",
		extensions = { "jl" },
		filetypes = { "julia" },
		entrypoints = { "main.jl", "run.jl", "src/main.jl" },
		run = function(ctx)
			return "julia " .. util.q(ctx.entry)
		end,
	},

	{
		id = "elixir",
		label = "Elixir",
		kind = "interpreted",
		extensions = { "ex", "exs" },
		filetypes = { "elixir" },
		entrypoints = { "main.exs", "run.exs", "lib/main.ex" },
		run = function(ctx)
			return "elixir " .. util.q(ctx.entry)
		end,
	},

	{
		id = "haskell",
		label = "Haskell",
		kind = "interpreted",
		extensions = { "hs", "lhs" },
		filetypes = { "haskell" },
		entrypoints = { "main.hs", "app/Main.hs", "src/Main.hs" },
		find_entry = function(root)
			return files_containing(root, { "hs", "lhs" }, "main%s*=")
		end,
		run = function(ctx)
			local runner = util.first_executable("runghc", "runhaskell") or "runghc"
			return runner .. " " .. util.q(ctx.entry)
		end,
	},

	{
		id = "scala",
		label = "Scala",
		kind = "interpreted",
		extensions = { "scala", "sc" },
		filetypes = { "scala" },
		entrypoints = { "Main.scala", "main.scala", "src/main/scala/Main.scala" },
		find_entry = function(root)
			return files_containing(root, { "scala", "sc" }, "def%s+main%s*%(")
		end,
		run = function(ctx)
			return "scala " .. util.q(ctx.entry)
		end,
	},

	{
		id = "sh",
		label = "Shell",
		kind = "interpreted",
		extensions = { "sh", "bash", "zsh" },
		filetypes = { "sh", "bash", "zsh" },
		entrypoints = { "run.sh", "main.sh", "start.sh", "scripts/run.sh" },
		run = function(ctx)
			local shell = util.first_executable("bash", "sh") or "sh"
			return shell .. " " .. util.q(ctx.entry)
		end,
	},

	{
		id = "html",
		label = "HTML",
		kind = "interpreted",
		extensions = { "html", "htm" },
		filetypes = { "html" },
		entrypoints = { "index.html", "public/index.html", "src/index.html" },
		run = function(ctx)
			local opener
			if util.is_windows() then
				opener = "cmd.exe /c start "
			elseif vim.fn.has("mac") == 1 then
				opener = "open "
			else
				opener = "xdg-open "
			end
			return opener .. util.q(ctx.entry)
		end,
	},

	{
		id = "clojure",
		label = "Clojure",
		kind = "interpreted",
		extensions = { "clj", "cljs", "cljc", "edn" },
		filetypes = { "clojure" },
		entrypoints = { "main.clj", "core.clj", "src/main.clj" },
		run = function(ctx)
			local runner = util.first_executable("clojure", "bb") or "clojure"
			return runner .. " " .. util.q(ctx.entry)
		end,
	},

	{
		id = "groovy",
		label = "Groovy",
		kind = "interpreted",
		extensions = { "groovy" },
		filetypes = { "groovy" },
		entrypoints = { "main.groovy", "app.groovy", "src/main.groovy" },
		run = function(ctx)
			return "groovy " .. util.q(ctx.entry)
		end,
	},

	{
		id = "ocaml",
		label = "OCaml",
		kind = "interpreted",
		extensions = { "ml", "mll" },
		filetypes = { "ocaml" },
		entrypoints = { "main.ml", "src/main.ml" },
		run = function(ctx)
			return "ocaml " .. util.q(ctx.entry)
		end,
	},

	{
		id = "gleam",
		label = "Gleam",
		kind = "compiled",
		extensions = { "gleam" },
		filetypes = { "gleam" },
		entrypoints = { "src/main.gleam", "src/app.gleam" },
		build = function()
			return "gleam build"
		end,
		run = function()
			return "gleam run"
		end,
	},

	{
		id = "fsharp",
		label = "F#",
		kind = "interpreted",
		extensions = { "fs", "fsx", "fsi" },
		filetypes = { "fsharp" },
		entrypoints = { "Program.fs", "Program.fsx", "main.fs", "main.fsx" },
		find_entry = function(root)
			return files_containing(root, { "fs", "fsx", "fsi" }, "[<]EntryPoint[>]")
		end,
		run = function(ctx)
			return "dotnet fsi " .. util.q(ctx.entry)
		end,
	},

	{
		id = "cs",
		label = "C#",
		kind = "compiled",
		extensions = { "cs" },
		filetypes = { "cs", "csharp" },
		entrypoints = { "Program.cs", "Main.cs", "src/Program.cs" },
	},

	{
		id = "vb",
		label = "Visual Basic",
		kind = "compiled",
		extensions = { "vb" },
		filetypes = { "vb" },
		entrypoints = { "Program.vb", "Module1.vb", "src/Program.vb" },
	},

	{
		id = "java",
		label = "Java",
		kind = "compiled",
		extensions = { "java" },
		filetypes = { "java" },
		entrypoints = { "Main.java", "src/Main.java", "src/main/java/Main.java", "App.java" },
		find_entry = function(root)
			return files_containing(root, { "java" }, "static%s+void%s+main%s*%(")
		end,
		build = function(ctx)
			local files = source_files(ctx, { "java" })
			local args = extra_args("java")
			local content = util.read_file(ctx.entry) or ""
			local package = content:match("^%s*package%s+([%w_%.]+)%s*;")
			local class = util.stem(ctx.entry)
			local main_class = package and (package .. "." .. class) or class
			local classes_dir = util.join(ctx.build_dir, "classes")
			local jar = util.join(ctx.build_dir, ctx.name .. ".jar")
			local javac_args = args ~= "" and (args .. " ") or ""
			local command = "mkdir -p "
				.. util.q(classes_dir)
				.. " && javac "
				.. javac_args
				.. "-d "
				.. util.q(classes_dir)
				.. " "
				.. util.quote_all(files)
				.. " && jar --create --file "
				.. util.q(jar)
				.. " --main-class "
				.. util.q(main_class)
				.. " -C "
				.. util.q(classes_dir)
				.. " ."
			return command
		end,
		run = function(ctx)
			return "java -jar " .. util.q(util.join(ctx.build_dir, ctx.name .. ".jar"))
		end,
	},

	{
		id = "kotlin",
		label = "Kotlin",
		kind = "compiled",
		extensions = { "kt", "kts" },
		filetypes = { "kotlin" },
		entrypoints = { "Main.kt", "main.kt", "src/Main.kt", "src/main/kotlin/Main.kt", "App.kt" },
		find_entry = function(root)
			return files_containing(root, { "kt", "kts" }, "fun%s+main%s*%(")
		end,
		build = function(ctx)
			local files = source_files(ctx, { "kt", "kts" })
			local jar = util.join(ctx.build_dir, ctx.name .. ".jar")
			local args = extra_args("kotlin")
			local command = "mkdir -p "
				.. util.q(ctx.build_dir)
				.. " && kotlinc "
				.. util.quote_all(files)
				.. " -include-runtime -d "
				.. util.q(jar)
			if args ~= "" then
				command = command .. " " .. args
			end
			return command
		end,
		run = function(ctx)
			return "java -jar " .. util.q(util.join(ctx.build_dir, ctx.name .. ".jar"))
		end,
	},

	{
		id = "rust",
		label = "Rust",
		kind = "compiled",
		extensions = { "rs" },
		filetypes = { "rust" },
		entrypoints = { "src/main.rs", "main.rs", "src/bin/main.rs" },
		find_entry = function(root)
			return files_containing(root, { "rs" }, "fn%s+main%s*%(")
		end,
		build = function(ctx)
			local args = extra_args("rust")
			local command = "mkdir -p "
				.. util.q(ctx.build_dir)
				.. " && rustc -O "
				.. util.q(ctx.entry)
				.. " -o "
				.. util.q(ctx.exe)
			if args ~= "" then
				command = command .. " " .. args
			end
			return command
		end,
		run = function(ctx)
			return util.q(ctx.exe)
		end,
	},

	{
		id = "go",
		label = "Go",
		kind = "compiled",
		extensions = { "go" },
		filetypes = { "go" },
		entrypoints = { "main.go", "cmd/main/main.go", "src/main.go" },
		find_entry = function(root)
			local path = files_containing(root, { "go" }, "package%s+main")
			if path then
				local content = util.read_file(path) or ""
				if content:find("func%s+main%s*%(") then
					return path
				end
			end
			return files_containing(root, { "go" }, "func%s+main%s*%(")
		end,
		build = function(ctx)
			local package_dir = util.dirname(ctx.entry)
			local relative = util.relative(ctx.root, package_dir):gsub("\\", "/")
			local package = relative == "." and "." or ("./" .. relative)
			local args = extra_args("go")
			local command = "mkdir -p "
				.. util.q(ctx.build_dir)
				.. " && go build -o "
				.. util.q(ctx.exe)
				.. " "
				.. util.q(package)
			if args ~= "" then
				command = command .. " " .. args
			end
			return command
		end,
		run = function(ctx)
			return util.q(ctx.exe)
		end,
	},

	{
		id = "c",
		label = "C",
		kind = "compiled",
		extensions = { "c" },
		filetypes = { "c" },
		entrypoints = { "main.c", "src/main.c", "src/c/main.c" },
		find_entry = function(root)
			return files_containing(root, { "c" }, "int%s+main%s*%(")
		end,
		build = function(ctx)
			local compiler = util.first_executable("cc", "gcc", "clang") or "cc"
			local files = source_files(ctx, { "c" })
			local args = extra_args("c")
			local command = "mkdir -p "
				.. util.q(ctx.build_dir)
				.. " && "
				.. compiler
				.. " -O2 -o "
				.. util.q(ctx.exe)
				.. " "
				.. util.quote_all(files)
			if args ~= "" then
				command = command .. " " .. args
			end
			return command
		end,
		run = function(ctx)
			return util.q(ctx.exe)
		end,
	},

	{
		id = "cpp",
		label = "C++",
		kind = "compiled",
		extensions = { "cpp", "cc", "cxx", "c++", "hpp", "hh", "hxx" },
		filetypes = { "cpp", "c++" },
		entrypoints = { "main.cpp", "main.cc", "src/main.cpp", "src/cpp/main.cpp" },
		find_entry = function(root)
			return files_containing(root, { "cpp", "cc", "cxx", "c++" }, "int%s+main%s*%(")
		end,
		build = function(ctx)
			local compiler = util.first_executable("c++", "g++", "clang++") or "c++"
			local files = source_files(ctx, { "cpp", "cc", "cxx", "c++", "c" })
			local args = extra_args("cpp")
			local command = "mkdir -p "
				.. util.q(ctx.build_dir)
				.. " && "
				.. compiler
				.. " -O2 -o "
				.. util.q(ctx.exe)
				.. " "
				.. util.quote_all(files)
			if args ~= "" then
				command = command .. " " .. args
			end
			return command
		end,
		run = function(ctx)
			return util.q(ctx.exe)
		end,
	},

	{
		id = "zig",
		label = "Zig",
		kind = "compiled",
		extensions = { "zig" },
		filetypes = { "zig" },
		entrypoints = { "src/main.zig", "main.zig", "src/app.zig" },
		find_entry = function(root)
			return files_containing(root, { "zig" }, "pub%s+fn%s+main%s*%(")
		end,
		build = function(ctx)
			local args = extra_args("zig")
			local command = "mkdir -p "
				.. util.q(ctx.build_dir)
				.. " && zig build-exe "
				.. util.q(ctx.entry)
				.. " -O ReleaseFast -femit-bin="
				.. util.q(ctx.exe)
			if args ~= "" then
				command = command .. " " .. args
			end
			return command
		end,
		run = function(ctx)
			return util.q(ctx.exe)
		end,
	},

	{
		id = "swift",
		label = "Swift",
		kind = "compiled",
		extensions = { "swift" },
		filetypes = { "swift" },
		entrypoints = { "main.swift", "Sources/main.swift", "Sources/App/main.swift" },
		find_entry = function(root)
			return files_containing(root, { "swift" }, "@main")
		end,
		build = function(ctx)
			local args = extra_args("swift")
			local command = "mkdir -p "
				.. util.q(ctx.build_dir)
				.. " && swiftc -O "
				.. util.q(ctx.entry)
				.. " -o "
				.. util.q(ctx.exe)
			if args ~= "" then
				command = command .. " " .. args
			end
			return command
		end,
		run = function(ctx)
			return util.q(ctx.exe)
		end,
	},

	{
		id = "dart",
		label = "Dart",
		kind = "interpreted",
		extensions = { "dart" },
		filetypes = { "dart" },
		entrypoints = { "bin/main.dart", "lib/main.dart", "main.dart" },
		run = function(ctx)
			return "dart run " .. util.q(ctx.entry)
		end,
	},

	{
		id = "fortran",
		label = "Fortran",
		kind = "compiled",
		extensions = { "f90", "f95", "f03", "f08", "f" },
		filetypes = { "fortran" },
		entrypoints = { "main.f90", "main.f95", "src/main.f90" },
		find_entry = function(root)
			return files_containing(root, { "f90", "f95", "f03", "f08", "f" }, "program%s+%w+")
		end,
		build = function(ctx)
			local files = source_files(ctx, { "f90", "f95", "f03", "f08", "f" })
			local args = extra_args("fortran")
			local command = "mkdir -p "
				.. util.q(ctx.build_dir)
				.. " && gfortran -O2 -o "
				.. util.q(ctx.exe)
				.. " "
				.. util.quote_all(files)
			if args ~= "" then
				command = command .. " " .. args
			end
			return command
		end,
		run = function(ctx)
			return util.q(ctx.exe)
		end,
	},

	{
		id = "asm",
		label = "Assembly",
		kind = "compiled",
		extensions = { "asm", "s" },
		filetypes = { "asm", "nasm" },
		entrypoints = { "main.asm", "main.s", "src/main.asm", "src/main.s" },
		build = function(ctx)
			local object = util.join(ctx.build_dir, ctx.name .. ".o")
			local args = extra_args("asm")
			local command = "mkdir -p "
				.. util.q(ctx.build_dir)
				.. " && nasm -f elf64 "
				.. util.q(ctx.entry)
				.. " -o "
				.. util.q(object)
				.. " && ld "
				.. util.q(object)
				.. " -o "
				.. util.q(ctx.exe)
			if args ~= "" then
				command = command .. " " .. args
			end
			return command
		end,
		run = function(ctx)
			return util.q(ctx.exe)
		end,
	},

	{
		id = "nim",
		label = "Nim",
		kind = "compiled",
		extensions = { "nim" },
		filetypes = { "nim" },
		entrypoints = { "main.nim", "src/main.nim" },
		find_entry = function(root)
			return files_containing(root, { "nim" }, "proc%s+main")
		end,
		build = function(ctx)
			local args = extra_args("nim")
			local command = "mkdir -p "
				.. util.q(ctx.build_dir)
				.. " && nim c -d:release --out:"
				.. util.q(ctx.exe)
				.. " "
				.. util.q(ctx.entry)
			if args ~= "" then
				command = command .. " " .. args
			end
			return command
		end,
		run = function(ctx)
			return util.q(ctx.exe)
		end,
	},

	{
		id = "crystal",
		label = "Crystal",
		kind = "compiled",
		extensions = { "cr" },
		filetypes = { "crystal" },
		entrypoints = { "src/main.cr", "main.cr" },
		build = function(ctx)
			local args = extra_args("crystal")
			local command = "mkdir -p "
				.. util.q(ctx.build_dir)
				.. " && crystal build --release -o "
				.. util.q(ctx.exe)
				.. " "
				.. util.q(ctx.entry)
			if args ~= "" then
				command = command .. " " .. args
			end
			return command
		end,
		run = function(ctx)
			return util.q(ctx.exe)
		end,
	},

	{
		id = "d",
		label = "D",
		kind = "compiled",
		extensions = { "d" },
		filetypes = { "d" },
		entrypoints = { "source/main.d", "src/main.d", "main.d" },
		find_entry = function(root)
			return files_containing(root, { "d" }, "void%s+main%s*%(")
		end,
		build = function(ctx)
			local compiler = util.first_executable("dmd", "ldc2", "gdc") or "dmd"
			local args = extra_args("d")
			local output_flag = compiler == "gdc" and ("-o " .. util.q(ctx.exe)) or ("-of=" .. util.q(ctx.exe))
			local command = "mkdir -p "
				.. util.q(ctx.build_dir)
				.. " && "
				.. compiler
				.. " -O "
				.. output_flag
				.. " "
				.. util.q(ctx.entry)
			if args ~= "" then
				command = command .. " " .. args
			end
			return command
		end,
		run = function(ctx)
			return util.q(ctx.exe)
		end,
	},
}

--------------------------------------------------------------------------------
-- Registry
--------------------------------------------------------------------------------

M.list = languages
M.by_id = {}
M.by_extension = {}
M.by_filetype = {}

for _, language in ipairs(languages) do
	M.by_id[language.id] = language
	for _, extension in ipairs(language.extensions or {}) do
		M.by_extension[extension:lower()] = language
	end
	for _, filetype in ipairs(language.filetypes or {}) do
		M.by_filetype[filetype] = language
	end
end

-- Aliases used by different Neovim filetype plugins.
local filetype_aliases = {
	bash = "sh",
	zsh = "sh",
	javascriptreact = "javascript",
	typescriptreact = "typescript",
	csharp = "cs",
	["c++"] = "cpp",
	objc = "c",
}

for alias, target in pairs(filetype_aliases) do
	M.by_filetype[alias] = M.by_id[target]
end

--- Resolve a language provider from an extension.
--- @param extension string
--- @return table|nil
function M.from_extension(extension)
	return M.by_extension[(extension or ""):lower()]
end

--- Resolve a language provider from a buffer's filetype/extension.
--- @param bufnr integer|nil
--- @return table|nil
function M.from_buffer(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local filetype = vim.bo[bufnr].filetype
	if filetype and filetype ~= "" then
		local language = M.by_filetype[filetype]
		if language then
			return language
		end
	end

	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return nil
	end
	return M.from_extension(util.extension(name))
end

-- Expose a few interpreter helpers so build-tool providers can reuse them.
M.python_command = python_command
M.javascript_command = javascript_command
M.typescript_command = typescript_command
M.ruby_command = ruby_command

--- Find the most likely entry point for a language.
--- @param id string
--- @param root string
--- @return string|nil
function M.entrypoint(id, root)
	local language = M.by_id[id]
	if not language then
		return nil
	end

	local explicit = candidate_paths(root, language.entrypoints)
	if explicit then
		return explicit
	end

	if language.find_entry then
		local found = language.find_entry(root)
		if found then
			return found
		end
	end

	local files = files_from_stems(root, language.extensions or {})
	return files[1]
end

return M
