--- Small, dependency-free helpers used by `custom.code_runner..
---
--- Everything in this module only uses Neovim's built-in Lua API (`vim.*`,
--- `vim.uv`, `io`, `os`).  No external plugin is required.
---
--- @class ProjectRunner.Util
local M = {}

local uv = vim.uv or vim.loop

--------------------------------------------------------------------------------
-- Platform / shell helpers
--------------------------------------------------------------------------------

--- Return true when Neovim is running on Windows.
--- @return boolean
function M.is_windows()
	return vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
end

--- Shell-quote a value (path, argument, ...).
--- @param value string|number|nil
--- @return string
function M.q(value)
	if value == nil then
		return ""
	end
	return vim.fn.shellescape(tostring(value))
end

--- Return the first executable found in a list of command names.
--- @param ... string
--- @return string|nil
function M.first_executable(...)
	for _, name in ipairs({ ... }) do
		if vim.fn.executable(name) == 1 then
			return name
		end
	end
	return nil
end

--- True when a command can be found in `$PATH`.
--- @param name string
--- @return boolean
function M.which(name)
	return vim.fn.executable(name) == 1
end

--------------------------------------------------------------------------------
-- Path helpers
--------------------------------------------------------------------------------

--- Join path segments with the platform separator.
--- @param ... string|nil
--- @return string
function M.join(...)
	local parts = {}
	for index = 1, select("#", ...) do
		local part = select(index, ...)
		if part ~= nil then
			part = tostring(part):gsub("\\", "/")
			if #parts == 0 then
				part = part:gsub("/+$", "")
			else
				part = part:gsub("^/+", ""):gsub("/+$", "")
			end
			if part ~= "" then
				parts[#parts + 1] = part
			end
		end
	end

	local result = table.concat(parts, "/")
	if result == "" then
		result = "."
	end
	if M.is_windows() then
		result = result:gsub("/", "\\")
	end
	return result
end

--- Convert a path to an absolute, normalized path without a trailing slash.
--- @param path string
--- @return string
function M.abspath(path)
	if path == nil or path == "" then
		return ""
	end

	local absolute = vim.fn.fnamemodify(path, ":p")
	absolute = absolute:gsub("[/\\]+$", "")
	if absolute == "" then
		absolute = M.is_windows() and vim.fn.getcwd() or "/"
	end
	return absolute
end

--- Basename of a path.
--- @param path string
--- @return string
function M.basename(path)
	return vim.fn.fnamemodify(path, ":t")
end

--- Directory part of a path.
--- @param path string
--- @return string
function M.dirname(path)
	return vim.fn.fnamemodify(path, ":h")
end

--- Path without its final extension.
--- @param path string
--- @return string
function M.stem(path)
	return vim.fn.fnamemodify(path, ":t:r")
end

--- File extension, without the dot, lower-cased.
--- @param path string
--- @return string
function M.extension(path)
	return vim.fn.fnamemodify(path, ":e"):lower()
end

--- Return `path` relative to `root` when possible.
--- @param root string
--- @param path string
--- @return string
function M.relative(root, path)
	local normalized_root = M.abspath(root):gsub("\\", "/")
	local normalized_path = M.abspath(path):gsub("\\", "/")

	if normalized_path == normalized_root then
		return "."
	end

	local prefix = normalized_root == "/" and "/" or (normalized_root .. "/")
	if normalized_path:sub(1, #prefix) == prefix then
		return normalized_path:sub(#prefix + 1)
	end
	return normalized_path
end

--- Number of path components below `root`.
--- @param root string
--- @param path string
--- @return integer
function M.depth(root, path)
	local relative = M.relative(root, path):gsub("\\", "/")
	if relative == "." then
		return 0
	end
	local count = 1
	for _ in relative:gmatch("/") do
		count = count + 1
	end
	return count
end

--- Sort paths shallowest first, then alphabetically.
--- @param paths string[]
--- @param root string
--- @return string[]
function M.sort_by_depth(paths, root)
	table.sort(paths, function(a, b)
		local depth_a = M.depth(root, a)
		local depth_b = M.depth(root, b)
		if depth_a ~= depth_b then
			return depth_a < depth_b
		end
		return a < b
	end)
	return paths
end

--------------------------------------------------------------------------------
-- Filesystem helpers
--------------------------------------------------------------------------------

--- True when a path exists (file, directory, symlink, ...).
--- @param path string
--- @return boolean
function M.exists(path)
	return uv.fs_stat(path) ~= nil
end

--- True when `path` exists and is a regular file.
--- @param path string
--- @return boolean
function M.is_file(path)
	local stat = uv.fs_stat(path)
	return stat ~= nil and stat.type == "file"
end

--- True when `path` exists and is a directory.
--- @param path string
--- @return boolean
function M.is_dir(path)
	local stat = uv.fs_stat(path)
	return stat ~= nil and stat.type == "directory"
end

--- Read a whole file.  Returns nil when the file cannot be read.
--- @param path string
--- @return string|nil
function M.read_file(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end
	local content = file:read("*a")
	file:close()
	return content
end

--- Read the first `max_lines` lines of a file.
--- @param path string
--- @param max_lines integer|nil
--- @return string[]
function M.read_lines(path, max_lines)
	local lines = {}
	local file = io.open(path, "r")
	if not file then
		return lines
	end

	for line in file:lines() do
		lines[#lines + 1] = line
		if max_lines and #lines >= max_lines then
			break
		end
	end
	file:close()
	return lines
end

--- List directory entries.  Returns `{ { name = "...", type = "file" }, ... }`.
--- @param path string
--- @return { name: string, type: string }[]
function M.list_dir(path)
	local result = {}
	local handle = uv.fs_scandir(path)
	if not handle then
		return result
	end

	while true do
		local name, entry_type = uv.fs_scandir_next(handle)
		if not name then
			break
		end
		result[#result + 1] = { name = name, type = entry_type or "unknown" }
	end
	return result
end

--- Evaluate a `globpath()` pattern relative to `root`.
--- @param root string
--- @param pattern string
--- @return string[]
function M.glob(root, pattern)
	local matches = vim.fn.globpath(root, pattern, false, true)
	local result = {}
	for _, path in ipairs(matches) do
		if M.is_file(path) then
			result[#result + 1] = M.abspath(path)
		end
	end
	return result
end

--- Find files with one of the given extensions below `root`.
--- @param root string
--- @param extensions string[]
--- @return string[]
function M.files_with_extensions(root, extensions)
	local files = {}
	local seen = {}

	for _, extension in ipairs(extensions) do
		for _, path in ipairs(M.glob(root, "**/*." .. extension)) do
			if not seen[path] then
				seen[path] = true
				files[#files + 1] = path
			end
		end
	end

	return M.sort_by_depth(files, root)
end

--- True when any component of `path` (relative to root) is in `ignored_dirs`.
--- @param path string
--- @param root string
--- @param ignored_dirs string[]
--- @return boolean
function M.is_ignored(path, root, ignored_dirs)
	local ignored = {}
	for _, name in ipairs(ignored_dirs or {}) do
		ignored[name] = true
	end

	local relative = M.relative(root, path):gsub("\\", "/")
	for component in relative:gmatch("[^/]+") do
		if ignored[component] then
			return true
		end
	end
	return false
end

--- Filter a list of paths, removing duplicates and ignored directories.
--- @param paths string[]
--- @param root string
--- @param ignored_dirs string[]
--- @return string[]
function M.clean_paths(paths, root, ignored_dirs)
	local result = {}
	local seen = {}
	for _, path in ipairs(paths) do
		local absolute = M.abspath(path)
		if not seen[absolute] and not M.is_ignored(absolute, root, ignored_dirs or {}) then
			seen[absolute] = true
			result[#result + 1] = absolute
		end
	end
	return M.sort_by_depth(result, root)
end

--------------------------------------------------------------------------------
-- Command helpers
--------------------------------------------------------------------------------

--- Join non-empty command fragments with `&&`.
--- @param parts (string|nil)[]
--- @return string|nil
function M.chain(parts)
	local commands = {}
	for _, part in ipairs(parts or {}) do
		if part and part ~= "" then
			commands[#commands + 1] = part
		end
	end
	if #commands == 0 then
		return nil
	end
	return table.concat(commands, " && ")
end

--- Quote a list of paths for a shell command.
--- @param paths string[]
--- @return string
function M.quote_all(paths)
	local quoted = {}
	for _, path in ipairs(paths) do
		quoted[#quoted + 1] = M.q(path)
	end
	return table.concat(quoted, " ")
end

--- Return the project root.
---
--- Per the plugin contract the root is Neovim's current working directory
--- (`:cd` / `:lcd`).  This keeps `.build`, the executable name and build-tool
--- detection predictable.
--- @return string
function M.root()
	return M.abspath(vim.fn.getcwd())
end

return M
