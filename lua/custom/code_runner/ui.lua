--- Minimal UI helpers built on `vim.ui.select` and floating windows.
---
--- No fzf, telescope, or other picker plugin is required.
local M = {}

local util = require "custom.code_runner.util"

--- Let the user choose one plan, or auto-select it when only one exists.
--- @param candidates table[]
--- @param prompt string|nil
--- @param callback fun(plan: table|nil)
function M.select_plan(candidates, prompt, callback)
	if #candidates == 0 then
		callback(nil)
		return
	end
	if #candidates == 1 then
		callback(candidates[1])
		return
	end

	vim.ui.select(candidates, {
		prompt = prompt or "Select project",
		kind = "code_runner",
		format_item = function(plan) return string.format("%s  [%s]", plan.label or plan.id or "project", plan.kind or "?") end,
	}, function(choice) callback(choice) end)
end

--- Close a floating window.
--- @param win integer
local function close_window(win)
	if win and vim.api.nvim_win_is_valid(win) then pcall(vim.api.nvim_win_close, win, true) end
end

--- Show a scrollable floating window with project details.
--- @param report table  Result returned by providers.resolve()
function M.show_info(report)
	local lines = {}
	local root = report.root or util.root()

	lines[#lines + 1] = "# Project Runner"
	lines[#lines + 1] = ""
	lines[#lines + 1] = "**Root:** `" .. root .. "`"
	local build_dir = report.candidates[1] and report.candidates[1].build_dir or (root .. "/.build")
	lines[#lines + 1] = "**Build dir:** `" .. build_dir .. "`"
	lines[#lines + 1] = ""

	if #report.tools > 0 then
		local detected = {}
		for _, hit in ipairs(report.tools) do
			detected[#detected + 1] = hit.tool.label .. " (`" .. hit.marker .. "`)"
		end
		lines[#lines + 1] = "**Detected build tools:** " .. table.concat(detected, ", ")
	else
		lines[#lines + 1] = "**Detected build tools:** none"
	end
	lines[#lines + 1] = ""

	if #report.candidates == 0 then
		lines[#lines + 1] = "**No runnable project was detected.**"
		lines[#lines + 1] = ""
		lines[#lines + 1] = "Add an entry point such as `main.py`, `src/main.rs`, or a recognised"
		lines[#lines + 1] = "build-tool marker at the project root."
	else
		lines[#lines + 1] = "## Candidates"
		lines[#lines + 1] = ""
		for index, plan in ipairs(report.candidates) do
			lines[#lines + 1] = string.format("%d. **%s** (%s)", index, plan.label or plan.id, plan.kind or "?")
			if plan.entry then lines[#lines + 1] = "   - Entry: `" .. util.relative(root, plan.entry) .. "`" end
			lines[#lines + 1] = "   - Build: `" .. (plan.build or "—") .. "`"
			lines[#lines + 1] = "   - Run: `" .. (plan.run or "—") .. "`"
			lines[#lines + 1] = ""
		end
	end

	local width = math.max(50, math.min(110, vim.o.columns - 8))
	local height = math.max(6, math.min(#lines, vim.o.lines - 8))
	local row = math.max(1, math.floor((vim.o.lines - height) / 2))
	local col = math.max(1, math.floor((vim.o.columns - width) / 2))

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "markdown"

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		title = " Project Runner ",
		title_pos = "center",
		width = width,
		height = height,
		row = row,
		col = col,
	})

	vim.keymap.set("n", "q", function() close_window(win) end, { buffer = buf, desc = "Close project info" })
	vim.keymap.set("n", "<Esc>", function() close_window(win) end, { buffer = buf, desc = "Close project info" })
end

return M
