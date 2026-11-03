--- Self-contained terminal runner.
---
--- The runner uses Neovim's built-in `jobstart(..., { term = true })` API, so it
--- does not depend on nvterm, toggleterm, or any other terminal plugin.
local M = {}

local util = require("custom.code_runner.util")
local config = require("custom.code_runner.config")

local state = {
	job = nil,
	buf = nil,
	win = nil,
	running = false,
	stopping = false,
}

--------------------------------------------------------------------------------
-- Notifications
--------------------------------------------------------------------------------

--- @param message string
--- @param level integer|nil
local function notify(message, level)
	if config.get().notify == false and (level or vim.log.levels.INFO) == vim.log.levels.INFO then
		return
	end
	vim.notify(message, level or vim.log.levels.INFO, { title = "Project Runner" })
end

M.notify = notify

--------------------------------------------------------------------------------
-- Window / process helpers
--------------------------------------------------------------------------------

--- Close the terminal window created by the previous run, if it is still open.
local function cleanup_previous()
	if state.job then
		pcall(vim.fn.jobstop, state.job)
	end

	local win = state.win
	local buf = state.buf
	state.job = nil
	state.buf = nil
	state.win = nil
	state.running = false
	state.stopping = false

	if win and vim.api.nvim_win_is_valid(win) then
		if buf and vim.api.nvim_win_get_buf(win) == buf then
			pcall(vim.api.nvim_win_close, win, true)
		end
	end

	if buf and vim.api.nvim_buf_is_valid(buf) then
		pcall(vim.api.nvim_buf_delete, buf, { force = true })
	end
end

--- Open a fresh terminal window and return its buffer id.
--- @return integer
local function open_terminal_window()
	local terminal = config.get().terminal or {}
	local direction = terminal.direction or "botright split"

	vim.cmd(direction)
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(win, buf)
	vim.bo[buf].swapfile = false
	vim.bo[buf].buflisted = false
	vim.bo[buf].bufhidden = "hide"

	if direction:find("split", 1, true) then
		if direction:find("vertical", 1, true) then
			local width
			if terminal.width_ratio then
				width = math.max(1, math.floor(vim.o.columns * terminal.width_ratio))
			else
				width = terminal.width or 30
			end
			pcall(vim.api.nvim_win_set_width, win, width)
		else
			pcall(vim.api.nvim_win_set_height, win, terminal.height or 15)
		end
	end

	state.win = win
	state.buf = buf
	return buf
end

--- Prefix a shell command with configured environment variables.
--- @param command string
--- @return string
local function with_environment(command)
	local env = config.get().env or {}
	local exports = {}
	for key, value in pairs(env) do
		exports[#exports + 1] = "export " .. key .. "=" .. util.q(value)
	end
	if #exports == 0 then
		return command
	end
	return table.concat(exports, "; ") .. "; " .. command
end

--- @param plan table
--- @param mode "all"|"build"|"run"
--- @return string|nil
local function command_for(plan, mode)
	if mode == "build" then
		return plan.build
	end
	if mode == "run" then
		return plan.run
	end

	-- Build the list explicitly: `{ plan.build, plan.run }` would start with a
	-- nil hole for interpreted projects, and `ipairs` in `util.chain` would
	-- stop immediately.
	local parts = {}
	if plan.build and plan.build ~= "" then
		parts[#parts + 1] = plan.build
	end
	if plan.run and plan.run ~= "" then
		parts[#parts + 1] = plan.run
	end
	return util.chain(parts)
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- True when a project process is currently running.
--- @return boolean
function M.is_running()
	return state.running
end

--- Stop the currently running project process.
function M.stop()
	if not state.job then
		notify("No project process is running.", vim.log.levels.WARN)
		return
	end

	state.stopping = true
	local job = state.job

	-- Try a polite Ctrl-C first; force-stop shortly afterwards.
	pcall(vim.fn.chansend, job, "\3")
	vim.defer_fn(function()
		if state.job == job then
			pcall(vim.fn.jobstop, job)
		end
	end, 300)

	notify("Stopping project process...", vim.log.levels.WARN)
end

--- Run, build, or re-run a resolved plan.
--- @param plan table
--- @param opts table|nil  { mode = "all"|"build"|"run" }
--- @return boolean
function M.run(plan, opts)
	opts = opts or {}
	local mode = opts.mode or "all"

	if not plan then
		notify("Could not detect a runnable project.", vim.log.levels.ERROR)
		return false
	end

	local command = command_for(plan, mode)
	if not command or command == "" then
		local action = mode == "build" and "build step" or "run command"
		notify("This project has no " .. action .. ".", vim.log.levels.WARN)
		return false
	end

	cleanup_previous()

	local label = plan.label or plan.id or "project"
	notify(
		(mode == "build" and "Building %s" or mode == "run" and "Running %s" or "Building and running %s"):format(label)
	)

	local buf = open_terminal_window()
	local cmd = util.is_windows() and { "cmd.exe", "/C", with_environment(command) }
		or { vim.o.shell or "sh", "-c", with_environment(command) }

	-- Declare `job` before assigning it so the `on_exit` closure captures it as
	-- an upvalue. A single `local job = jobstart(...)` declaration would leave
	-- `job` out of scope inside the callback (it would resolve to the global).
	local job
	job = vim.fn.jobstart(cmd, {
		term = true,
		cwd = plan.root,
		on_exit = function(_, code)
			vim.schedule(function()
				if state.job ~= job then
					return
				end

				local was_stopping = state.stopping
				state.job = nil
				state.running = false
				state.stopping = false

				if was_stopping then
					notify("Project process stopped.", vim.log.levels.WARN)
				elseif code == 0 then
					notify("Project finished successfully (exit 0).")
				else
					notify("Project exited with code " .. tostring(code) .. ".", vim.log.levels.ERROR)
				end
			end)
		end,
	})

	if job <= 0 then
		state.running = false
		notify("Failed to start the project process.", vim.log.levels.ERROR)
		return false
	end

	state.job = job
	state.running = true
	state.stopping = false

	-- Give the terminal buffer a stable name, and make `q` close it in normal
	-- mode without interfering with the running process.
	pcall(vim.api.nvim_buf_set_name, buf, "code_runner.//" .. (plan.id or "project"))
	vim.keymap.set("n", "q", function()
		if state.running then
			notify("Process is still running. Use :ProjectStop first.", vim.log.levels.WARN)
			return
		end
		if state.win and vim.api.nvim_win_is_valid(state.win) then
			pcall(vim.api.nvim_win_close, state.win, true)
		end
	end, { buffer = buf, desc = "Close project terminal" })

	vim.cmd("startinsert")
	return true
end

return M
