local autocmd = vim.api.nvim_create_autocmd

--- augroup helper function ----------------------------------------------------

local function augroup(name, opts)
	opts = opts or { clear = true }
	return vim.api.nvim_create_augroup("scratch_" .. name, opts)
end

---------------------------------------------------------------------------------
---- MAKE SPECIAL BUFFERS "UNLISTED" AND PREVENT THEM FROM BEING REPLACED:
---------------------------------------------------------------------------------
autocmd("BufEnter", {
	pattern = { "term://*", "qf", "help", "oil://*", "copilot-*", "man" },
	callback = function()
		vim.bo.buflisted = false
		vim.bo.bufhidden = "hide"
	end,
})

---------------------------------------------------------------------------------
---- RESTORE_CURSOR  go to last loc when opening a buffer
---------------------------------------------------------------------------------
autocmd("BufReadPost", {
	group = augroup "last_loc",
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then return end
		vim.b[buf].lazyvim_last_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
	end,
})

---------------------------------------------------------------------------------
----RESTORE SAVED BACKGROUND COLOR
--------------------------------------------------------------------------------
autocmd("UIEnter", {
	callback = function() require("custom.bg_change").load_bg() end,
})

---------------------------------------------------------------------------------
---- HELP WINDOW OPEN IN VERTICAL SPLIT
---------------------------------------------------------------------------------
autocmd("FileType", {
	pattern = "help",
	callback = function() vim.cmd "wincmd L" end,
})

---------------------------------------------------------------------------------
---- CLOSE THE FOLLOWING PATTERN WITH `Q`
---------------------------------------------------------------------------------
autocmd("FileType", {
	pattern = {
		"checkhealth",
		"qf",
		"help",
		"man",
		"lspinfo",
		"PlenaryTestPopup",
		"checkhealth",
		"dap-float",
		"dbout",
		"gitsigns-blame",
		"grug-far",
		"help",
		"lspinfo",
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
		"notify",
		"qf",
		"spectre_panel",
		"startuptime",
		"tsplayground",
	},
	callback = function() vim.keymap.set("n", "q", ":close<CR>", { noremap = true, silent = true }) end,
})

---------------------------------------------------------------------------------
---- C/C++ HEADER TOGGLE
---------------------------------------------------------------------------------
autocmd("FileType", {
	pattern = { "c", "cpp" },
	callback = function()
		vim.keymap.set(
			"n",
			"T",
			function() require("custom.header_switch").toggle() end,
			{ buffer = true, desc = "Toggle between header and implementation files" }
		)
	end,
})

---------------------------------------------------------------------------------
---- DISABLE AUTO-COMMENT ON NEW LINE
---------------------------------------------------------------------------------
autocmd("FileType", {
	pattern = "*",
	callback = function() vim.opt_local.formatoptions:remove { "r", "o" } end,
})

---------------------------------------------------------------------------------
---- RESIZE SPLITS IF WINDOW GOT RESIZED
---------------------------------------------------------------------------------
vim.api.nvim_create_autocmd({ "VimResized" }, {
	group = augroup "resize_splits",
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd "tabdo wincmd ="
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
	group = augroup "json_conceal",
	pattern = { "json", "jsonc", "json5" },
	callback = function() vim.opt_local.conceallevel = 0 end,
})

---------------------------------------------------------------------------------
---- HIGHLIGHT ON YANK
---------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup "highlight_yank",
	callback = function()
		if vim.fn.has "nvim-0.13" == 1 then
			vim.hl.hl_op()
		else
			(vim.hl or vim.highlight).on_yank()
		end
	end,
})

---------------------------------------------------------------------------------
-- 'autoread' gets its own file watchers, so a file changed outside nvim is read
-- back without a :checktime on focus.
---------------------------------------------------------------------------------
local resize_timer
vim.api.nvim_create_autocmd("VimResized", {
	group = augroup "resize_splits",
	callback = function()
		if resize_timer then
			resize_timer:stop()
			resize_timer:close()
		end
		local tab = vim.fn.tabpagenr()
		resize_timer = vim.defer_fn(function()
			resize_timer = nil
			vim.cmd "tabdo wincmd ="
			vim.cmd("tabnext " .. tab)
		end, 100)
	end,
})

---------------------------------------------------------------------------------
---- CUSTOM USER COMMANDS
---------------------------------------------------------------------------------
-- CHANGE BACKGROUND COLOR
vim.api.nvim_create_user_command(
	"Bg",
	function() require("custom.bg_change").select_bg() end,
	{ desc = "Select Background Color" }
)

-- COLORSCHEME SELECT (current session only; startup theme is set in base.options)
vim.api.nvim_create_user_command(
	"Cp",
	function() require("fzf-lua").colorschemes { winopts = { height = 0.5, width = 0.5 } } end,
	{ desc = "Select ColorScheme" }
)
