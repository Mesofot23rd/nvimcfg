--- # project_runner
---
--- A small, self-contained Neovim project runner.
---
--- Features
---   * Detects common build tools from marker files at the project root.
---   * Falls back to language/entry-point detection when no build tool exists.
---   * Runs compiled-language builds inside `<root>/.build`.
---   * Runs the file in the current buffer as a standalone program.
---   * Names direct-compiler executables after the root directory.
---   * Uses Neovim's built-in terminal and `vim.ui.select` (no plugin deps).
---
--- Public API:
---   require("custom.code_runner.).setup(opts)
---   require("custom.code_runner.).run()
---   require("custom.code_runner.).build()
---   require("custom.code_runner.).run_only()
---   require("custom.code_runner.).run_file()
---   require("custom.code_runner.).stop()
---   require("custom.code_runner.).info()
---   require("custom.code_runner.).detect()
---
--- The module auto-configures with defaults when it is first required, so
--- adding `"custom.code_runner.` to `init.lua` is enough to get
--- `<leader>rp` and `<leader>rc`.  Calling `setup()` later overrides the
--- defaults.
local M = {}

local config = require "custom.code_runner.config"
local providers = require "custom.code_runner.providers"
local runner = require "custom.code_runner.runner"
local file_runner = require "custom.code_runner.file_runner"
local ui = require "custom.code_runner.ui"
local util = require "custom.code_runner.util"

M.config = config
M.util = util

local function notify(message, level) vim.notify(message, level or vim.log.levels.INFO, { title = "Project Runner" }) end

M._keymaps = {}

local function clear_keymaps()
	for _, entry in ipairs(M._keymaps or {}) do
		pcall(vim.keymap.del, entry.mode, entry.lhs)
	end
	M._keymaps = {}
end

local function set_keymap(lhs, rhs, description)
	if not lhs or lhs == false then return end
	vim.keymap.set("n", lhs, rhs, {
		noremap = true,
		silent = true,
		desc = description,
	})
	M._keymaps[#M._keymaps + 1] = { mode = "n", lhs = lhs }
end

--------------------------------------------------------------------------------
-- Core actions
--------------------------------------------------------------------------------

--- Resolve the current project without running anything.
--- @return table
function M.detect() return providers.resolve() end

--- Run the current project (build first when the provider needs a build).
function M.run()
	local report = providers.resolve()
	ui.select_plan(report.candidates, "Run project", function(plan)
		if plan then
			runner.run(plan, { mode = "all" })
		else
			notify("No runnable project found in " .. report.root, vim.log.levels.ERROR)
		end
	end)
end

--- Build the current project without running it.
function M.build()
	local report = providers.resolve()
	ui.select_plan(report.candidates, "Build project", function(plan)
		if plan then
			runner.run(plan, { mode = "build" })
		else
			notify("No buildable project found in " .. report.root, vim.log.levels.ERROR)
		end
	end)
end

--- Run an already-built project without invoking the build step.
function M.run_only()
	local report = providers.resolve()
	ui.select_plan(report.candidates, "Run project (skip build)", function(plan)
		if plan then
			runner.run(plan, { mode = "run" })
		else
			notify("No runnable project found in " .. report.root, vim.log.levels.ERROR)
		end
	end)
end

--- Run the file in the current buffer as a standalone program.
--- @param opts table|nil  { bufnr = integer }
--- @return boolean
function M.run_file(opts) return file_runner.run(opts) end

--- Stop the currently running project process.
function M.stop() runner.stop() end

--- Show detected tools, entry points, and exact commands.
function M.info() ui.show_info(providers.resolve()) end

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

--- Configure the plugin.  Safe to call more than once.
--- @param opts table|nil
function M.setup(opts)
	local options = config.merge(opts)

	clear_keymaps()

	vim.api.nvim_create_user_command(
		"ProjectRun",
		function() M.run() end,
		{ desc = "Run the current project", force = true }
	)

	vim.api.nvim_create_user_command(
		"ProjectBuild",
		function() M.build() end,
		{ desc = "Build the current project", force = true }
	)

	vim.api.nvim_create_user_command(
		"ProjectRunOnly",
		function() M.run_only() end,
		{ desc = "Run the current project without rebuilding", force = true }
	)

	vim.api.nvim_create_user_command(
		"ProjectRunFile",
		function() M.run_file() end,
		{ desc = "Run the current file as a standalone program", force = true }
	)

	vim.api.nvim_create_user_command(
		"ProjectStop",
		function() M.stop() end,
		{ desc = "Stop the running project", force = true }
	)

	vim.api.nvim_create_user_command(
		"ProjectInfo",
		function() M.info() end,
		{ desc = "Show detected project runner information", force = true }
	)

	set_keymap(options.keymap, function() M.run() end, "Run project")
	set_keymap(options.file_keymap, function() M.run_file() end, "Run current file")
	set_keymap(options.build_keymap, function() M.build() end, "Build project")
	set_keymap(options.info_keymap, function() M.info() end, "Code runner info")

	set_keymap("<leader>re", "<cmd>ProjectRunOnly<CR>", "Run project executable")
	set_keymap("<F2>", "<cmd>ProjectStop<CR>", "Stop code runner")

	M._configured = true
	return M
end

-- Auto-configure with defaults on first require.  An explicit `setup()` call
-- after this simply replaces the defaults with the user's options.
if not M._configured then M.setup() end

return M
