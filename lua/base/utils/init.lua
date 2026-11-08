--      -> set_tabulation
--      -> toggle_autoformat
--      -> toggle_autopairs
--      -> toggle_background
--      -> toggle_buffer_inlay_hints
--      -> toggle_buffer_syntax
--      -> toggle_css_colors
---      -> toggle_diagnostics
--      -> toggle_foldcolumn
--      -> toggle_inlay_hints
--      -> toggle_buffer_semantic_tokens
--      -> toggle_line_numbers
--      -> toggle_lsp_signature
--      -> toggle_signcolumn
--      -> toggle_spell
--      -> toggle_statusline
--      -> toggle_tablinr
--      -> toggle_notifications
--      -> toggle_url_hl
--      -> toggle_wrap

local toggle_option = require "base.utils.toggle_option"

-------------------------------------
----- Helper Functions
-------------------------------------

--- Check if a plugin is defined in lazy. Useful with lazy loading
--- when a plugin is not necessarily loaded yet.
--- @param plugin string The plugin to search for.
--- @return boolean available # Whether the plugin is available.
local function is_available(plugin)
	local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
	return lazy_config_avail and lazy_config.spec.plugins[plugin] ~= nil
end

--- Sends a notification with 'Neovim' as default title.
--- Same as using vim.notify, but it saves us typing the title every time.
--- @param msg string The notification body.
--- @param type number|nil The type of the notification (:help vim.log.levels).
--- @param opts? table The nvim-notify options to use (:help notify-options).

function notify(msg, type, opts)
	vim.schedule(function() vim.notify(msg, type, vim.tbl_deep_extend("force", { title = "Neovim" }, opts or {})) end)
end

-------------------------------------
----- Toggle Functions
-------------------------------------

--- Delete the syntax matching rules for URLs/URIs if set.
local function delete_url_hl()
	for _, match in ipairs(vim.fn.getmatches()) do
		if match.group == "HighlightURL" then vim.fn.matchdelete(match.id) end
	end
end

--- Set a highlight to apply to URLs.
local function set_url_hl()
	--- regex used for matching a valid URL/URI string
	local url_matcher = "\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)"
		.. "%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)"
		.. "[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|"
		.. "[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)"
		.. "|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*"
		.. "|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+"

	delete_url_hl()
	if vim.g.url_hl_enabled then -- set url hl
		vim.api.nvim_set_hl(0, "HighlightURL", { underline = true, bg = "NONE" })
		vim.fn.matchadd("HighlightURL", url_matcher, 15)
	end
end

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

--- toggle line_number -------------------------------------------------------------
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

--- toggle Spell check ----------------------------------------------------
toggle_option.new {
	map = "<leader>us",
	title = "Spell Check",
	get = function() return vim.wo.spell end,
	set = function(state) vim.wo.spell = state end,
}

-- --- toggle notify state ----------------------------------------------------
-- toggle_option.new {
-- 	map = "<leader>un",
-- 	title = "Notifications",
-- 	get = function() return vim.g.notifications_enabled end,
-- 	set = function(state) vim.g.notifications_enabled = state end,
-- }

--- toggle Url highlight ----------------------------------------------------
toggle_option.new {
	map = "<leader>uu",
	title = "Url Highlight",
	get = function() return vim.g.url_hl_enabled end,
	set = function(state)
		if state then
			delete_url_hl()
		else
			set_url_hl()
		end
	end,
}

-- --- toggle Dark Bg ----------------------------------------------------
-- --- It will only work if your colorscheme implements this feature.

-- toggle_option.new {
-- 	map = "<leader>uu",
-- 	title = "Dark Bg",
-- 	get = function() return vim.go.background=='dark' end,
-- 	set = function(state)

-- vim.go.background == "light" and "dark" or "light"
-- vim.go.background
--
--   end,
-- }

-- --- toggle statusline ----------------------------------------------------
-- -- 2=local 3=global 0=off
toggle_option.new {
	map = "<leader>uS",
	title = "Statusline",
	get = function() return vim.opt.laststatus:get() == 2 or vim.opt.laststatus:get() == 3 end,
	set = function(state)
		if state then
			vim.opt.laststatus = 0
		else
			vim.opt.laststatus = 2
		end
	end,
}

-- --- toggle tabline ----------------------------------------------------
-- toggle_option.new {
-- 	map = "<leader>uT",
-- 	title = "Tabline",
-- 	get = function() return vim.opt.showtabline:get() end,
-- 	set = function(state)
-- 		if state then
-- 			vim.opt.showtabline = 0
-- 		else
-- 			vim.opt.showtabline = 2
-- 		end
-- 	end,
-- }

-- -- toggle foldcoumn
-- toggle_option.new {
-- 	map = "<leader>uF",
-- 	title = "Foldcolumn",
-- 	get = function() return vim.wo.foldcolumn:get()==1 end,
-- 	set = function(state)
-- 		if state then
-- 			vim.opt.foldcolumn = 0
-- 		else
-- 			vim.opt.foldcolumn = 1
-- 		end
-- 	end,
-- }

-- -- toggle signcoumn
-- toggle_option.new {
-- 	map = "<leader>uF",
-- 	title = "Signcolumn",
-- 	get = function() 		return vim.wo.signcolumn == "no" end,
-- 	set = function(state)
-- 		if state then
-- 			vim.wo.signcolumn == "yes"
-- 		else
-- 			vim.wo.signcolumn == "no"
-- 		end
-- 		-- vim.wo.signcolumn == "auto"

-- 	end,
-- }

-- -- toggle signcoumn
-- toggle_option.new {
-- 	map = "<leader>uF",
-- 	title = "Conceal",
-- 	get = function() 		return vim.opt.conceallevel==2 end,
-- 	set = function(state)

-- 	vim.opt.conceallevel = vim.opt.conceallevel:get() == 0 and 2 or 0

-- 	end,
-- }

-- --- Toggle codelens
-- --- @param bufnr? number the buffer to toggle `codelens` on.
-- function M.toggle_codelens(bufnr)
-- 	bufnr = bufnr or 0
-- 	vim.g.codelens_enabled = not vim.g.codelens_enabled
-- 	if vim.g.codelens_enabled then
-- 		vim.lsp.codelens.refresh { bufnr = bufnr }
-- 	else
-- 		vim.lsp.codelens.clear()
-- 	end
-- 	utils.notify(string.format("Buffer [CodeLens]: `%s`", bool2str(vim.g.codelens_enabled)))
-- end

-- --- Toggle diagnostics
-- function M.toggle_diagnostics()
-- 	vim.g.diagnostics_mode = (vim.g.diagnostics_mode - 1) % 4
-- 	vim.diagnostic.config(require("base.utils").diagnostics_enum[vim.g.diagnostics_mode])
-- 	if vim.g.diagnostics_mode == 0 then
-- 		utils.notify "Global [LSP diagnostics mode]: `OFF`"
-- 	elseif vim.g.diagnostics_mode == 1 then
-- 		utils.notify "Global [LSP diagnostics mode]: `Statusbar only`"
-- 	elseif vim.g.diagnostics_mode == 2 then
-- 		utils.notify "Global [LSP diagnostics mode]: `Virtual text only`"
-- 	else
-- 		utils.notify "Global [LSP diagnostics mode]: `All diagnostics ON`"
-- 	end
-- end
-- -------------------------------------
-- ----- Plugin toggles
-- -------------------------------------

-- --- Toggle autopairs
local function toggle_autopairs()
	if not is_available "nvim-autopairs" then -- guard clause
		notify "Plugin 'autopairs.nvim' not available"
		return
	end
	local autopairs = require "nvim-autopairs"

	if autopairs.state.disabled then
		autopairs.enable()
	else
		autopairs.disable()
	end

	vim.g.autopairs_enabled = not autopairs.state.disabled
end

--- Toggle CSS #colors
local function toggle_css_colors()
	if not is_available "nvim-highlight-colors" then -- guard clause
		notify "Plugin 'nvim-highlight-colors' not available"
		return
	end

	vim.cmd "HighlightColors toggle"
	vim.g.color_highlight_enabled = not vim.g.color_highlight_enabled
end

--- Toggle coverage signs
local function toggle_coverage_signs()
	if not is_available "gitsigns.nvim" then -- guard clause
		notify "Plugin 'gitsigns' not available"
		return
	end

	vim.g.coverage_signs_enabled = not vim.g.coverage_signs_enabled
	vim.cmd "Gitsigns toggle_signs"
end

--- TODO: Toggle Mason

vim.keymap.set("n", "<leader>uH", function() toggle_css_colors() end)
vim.keymap.set("n", "<leader>uG", function() toggle_coverage_signs() end)
vim.keymap.set("n", "<leader>uP", function() toggle_autopairs() end)
