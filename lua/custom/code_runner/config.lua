--- Configuration for `custom.code_runner..
---
--- Call `require("custom.code_runner.).setup({ ... })` with any of the
--- values below to override the defaults.
local M = {}

M.defaults = {

	build_dir = ".build", --- Directory (relative to the project root) used for compiled artifacts.

	--- Name of the produced executable.  Defaults to the basename of the root
	--- directory.  Can be a string or a function(root) -> string.
	executable_name = nil,

	keymap = "<leader>rp", --- Key used to run the current project.  Set to `false` to disable.
	file_keymap = "<leader>rc", --- Key used to run the current file.  Set to `false` to disable.

	--- Optional extra keymaps.  `false` disables them.
	build_keymap = "<leader>rb", -- only build
	info_keymap = "<leader>ri", -- show detected project information

	notify = true, --- Show a notification with the selected provider before running.

	--- Terminal window used for builds/runs.
	terminal = {
		--- Any Ex command that opens a window.  Examples:
		---   "botright split" (horizontal, default)
		---   "botright vertical split"
		---   "tabnew"
		direction = "botright vertical split",
		height = 15, --- Height used for horizontal splits.  Ignored for `tabnew`.
		width_ratio = 0.4, --- Width ratio used for vertical splits (0.4 = 40% of the editor).
		width = 30, --- Fallback width for vertical splits when `width_ratio` is nil.
	},

	--- Directories ignored while searching for entry points and source files.
	ignored_dirs = {
		".git",
		".hg",
		".svn",
		".build",
		"node_modules",
		"target",
		"dist",
		"build",
		"out",
		"bin",
		"obj",
		"vendor",
		"venv",
		".venv",
		"__pycache__",
		".mypy_cache",
		".pytest_cache",
		".cache",
		"zig-cache",
		"zig-out",
		"CMakeFiles",
		"_build",
		"deps",
	},

	--- Extra arguments appended to compiled-language build commands.
	--- Example: { c = "-Wall -Wextra", cpp = "-Wall -Wextra" }
	build_args = {},

	--- Environment variables set for the build/run process.
	--- Example: { RUST_BACKTRACE = "1" }
	env = {},
}

M.options = vim.deepcopy(M.defaults)

--- Return the active configuration.
--- @return table
function M.get() return M.options end

--- Merge user options into the active configuration.
--- @param opts table|nil
--- @return table
function M.merge(opts)
	opts = opts or {}

	-- `ignored_dirs` should be replaceable as a list, not merged item-wise.
	local ignored_dirs = opts.ignored_dirs
	local build_args = opts.build_args
	local env = opts.env
	local callbacks = vim.deepcopy(opts)
	callbacks.ignored_dirs = nil
	callbacks.build_args = nil
	callbacks.env = nil

	M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), callbacks)
	if ignored_dirs then M.options.ignored_dirs = ignored_dirs end
	if build_args then M.options.build_args = build_args end
	if env then M.options.env = env end

	return M.options
end

return M
