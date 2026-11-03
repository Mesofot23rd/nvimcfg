-------------------------------------
----- TOGGLES
-------------------------------------

--- toggle wrap ----------------------------------------------------------------
toggle_option.new {
	map = "<leader>uw",
	title = "Wrap",
	get = function() return vim.wo.wrap end,
	set = function(state)
		vim.wo.wrap = state
		vim.wo.linebreak = state
	end,
}

--- toggle line number -------------------------------------------------------------
toggle_option.new {
	map = "<leader>ul",
	title = "Line Number",
	get = function() return vim.wo.number end,
	set = function(state) vim.wo.number = state end,
}

--- toggle relative numbers ----------------------------------------------------
toggle_option.new {
	map = "<leader>ur",
	title = "Relative Numbers",
	get = function() return vim.wo.relativenumber end,
	set = function(state) vim.wo.relativenumber = state end,
}

--- toggle notify state ----------------------------------------------------
toggle_option.new {
	map = "<leader>un",
	title = "Notifications",
	get = function() return vim.g.notifications_enabled end,
	set = function(state) vim.g.notifications_enabled = state end,
}

--- toggle Spell check ----------------------------------------------------
toggle_option.new {
	map = "<leader>us",
	title = "Spell Check",
	get = function() return vim.wo.spell end,
	set = function(state) vim.wo.spell = state end,
}

--- toggle Statusline (OFF -> LOCAL -> GLOBAL -> OFF) ----------------------
map(
	"n",
	"<leader>uS",
	function() require("base.utils.ui").toggle_statusline() end,
	desc "Statusline (off/local/global)"
)

--- toggle Url highlight ----------------------------------------------------
toggle_option.new {
	map = "<leader>uu",
	title = "Url Highlight",
	get = function() return vim.g.url_hl_enabled end,
	set = function(state) vim.g.url_hl_enabled = state end,
}
