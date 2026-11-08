--Git integration on neovim
local function notify(message, level) vim.notify(message, level or vim.log.levels.INFO, { title = "Git" }) end

-- Only ever operate on the current buffer, and only when it is a saved normal
-- file buffer. Special buffers (help, terminal, etc.) have no file to target.
local function buffer_file(action)
	local buf = vim.api.nvim_get_current_buf()
	local file = vim.api.nvim_buf_get_name(buf)

	if file == "" or vim.bo[buf].buftype ~= "" then
		notify("Current buffer is not a file", vim.log.levels.WARN)
		return nil
	end

	if vim.bo[buf].modified then
		notify("Save Buffer before " .. action, vim.log.levels.WARN)
		return nil
	end

	return file, buf
end

local function repo_root(file) return vim.fs.root(file, ".git") end

local function run_git(action, args, file, success, on_exit)
	local root = repo_root(file)
	if not root then
		notify("Not inside a Git repository", vim.log.levels.WARN)
		return
	end

	local cmd = { "git" }
	vim.list_extend(cmd, args)

	vim.system(cmd, { cwd = root, text = true }, function(result)
		vim.schedule(function()
			local ok = result.code == 0

			if ok then
				if success then notify(success) end
			else
				local details = vim.trim(result.stderr or "")
				if details == "" then details = vim.trim(result.stdout or "") end
				notify(action .. " failed" .. (details ~= "" and (": " .. details) or ""), vim.log.levels.ERROR)
			end

			if on_exit then on_exit(ok, result) end
		end)
	end)
end

local function add_file()
	local file = buffer_file "Git add"
	if not file then return end

	local name = vim.fn.fnamemodify(file, ":t")
	run_git("Git add", { "add", "--", file }, file, "Staged " .. name)
end

local function commit_file(file, message, action, success)
	run_git(action, { "commit", "-m", message, "--", file }, file, success)
end

local function commit_with_message()
	local file = buffer_file "Git commit"
	if not file then return end

	local name = vim.fn.fnamemodify(file, ":t")
	vim.ui.input({ prompt = "Commit message for " .. name .. ": " }, function(input)
		if input == nil then return end

		local message = vim.trim(input)
		if message == "" then
			notify("Commit cancelled: message is empty", vim.log.levels.WARN)
			return
		end

		commit_file(file, message, "Git commit", "Committed " .. name)
	end)
end

-- Git has no `--nomessage` flag. This is the literal equivalent: commit the
-- current file with an empty message and without opening an editor.
local function commit_without_message()
	local file = buffer_file "Git commit"
	if not file then return end

	local name = vim.fn.fnamemodify(file, ":t")
	run_git(
		"Git commit",
		{ "commit", "--allow-empty-message", "-m", "", "--", file },
		file,
		"Committed " .. name .. " (no message)"
	)
end

local function add_and_commit()
	local file = buffer_file "Git add & commit"
	if not file then return end

	local name = vim.fn.fnamemodify(file, ":t")
	vim.ui.input({ prompt = "Commit message for " .. name .. ": " }, function(input)
		if input == nil then return end

		local message = vim.trim(input)
		if message == "" then
			notify("Commit cancelled: message is empty", vim.log.levels.WARN)
			return
		end

		run_git("Git add", { "add", "--", file }, file, nil, function(ok)
			if ok then commit_file(file, message, "Git commit", "Committed " .. name) end
		end)
	end)
end

local function unstage_file()
	local file = buffer_file "Git reset"
	if not file then return end

	local name = vim.fn.fnamemodify(file, ":t")
	run_git("Git reset", { "reset", "-q", "--", file }, file, "Unstaged " .. name)
end

local function restore_file()
	local file, buf = buffer_file "Git restore"
	if not file then return end

	local name = vim.fn.fnamemodify(file, ":t")
	local choice =
		vim.fn.confirm("Discard all changes to " .. name .. " and restore it from HEAD?", "&Restore\n&Cancel", 2)
	if choice ~= 1 then return end

	run_git(
		"Git restore",
		{ "restore", "--source=HEAD", "--staged", "--worktree", "--", file },
		file,
		"Restored " .. name .. " from HEAD",
		function(ok)
			if not ok then return end

			if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_call(buf, function() vim.cmd "silent! edit!" end) end
		end
	)
end

-- File-scoped, read-only views handled by vim-fugitive.
local function fugitive_view(action, args)
	local file = buffer_file(action)
	if not file then return end

	local ok, err = pcall(vim.cmd, ("Git %s -- %s"):format(args, vim.fn.fnameescape(file)))
	if not ok then notify(action .. " failed: " .. err, vim.log.levels.ERROR) end
end

return {
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "G" },
		lazy = true,
		keys = {
			{ "<leader>ga", add_file, desc = "Git add file" },
			{ "<leader>gc", commit_with_message, desc = "Git commit file (prompt)" },
			{ "<leader>gC", commit_without_message, desc = "Git commit (no message)" },
			{ "<leader>gA", add_and_commit, desc = "Git add and commit (prompt)" },
			{ "<leader>gu", unstage_file, desc = "Git unstage file" },
			{ "<leader>gr", restore_file, desc = "Git restore file from HEAD" },
			{ "<leader>gd", function() fugitive_view("Git diff", "diff") end, desc = "Git diff file" },
			{
				"<leader>gD",
				function() fugitive_view("Git diff HEAD", "diff HEAD") end,
				desc = "Git diff current file against HEAD",
			},
			{ "<leader>gl", function() fugitive_view("Git log", "log") end, desc = "Git log file" },
			{ "<leader>gb", function() fugitive_view("Git blame", "blame") end, desc = "Git blame file" },
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		event = "BufReadPre",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			signs_staged = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},
}
