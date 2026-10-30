local M = {}

function M.reload(opts)
	if vim.g.colors_name then
		vim.cmd.highlight("clear")
	end
	if vim.fn.exists("syntax_on") then
		vim.cmd.syntax("reset")
	end
	vim.o.termguicolors = opts.termguicolors
	vim.g.colors_name = opts.palette
end

function M.get_plugin_list(opts)
	local lazy_avail, lazy_config = pcall(require, "lazy.core.config")
	local installed_plugins = lazy_avail and lazy_config.plugins or packer_plugins

	local plugins = {}

	for plugin, module in pairs(require("custom.theme.xnx-theme.groups.plugins")) do
		local load = opts.plugins[plugin]
		if load == nil then
			load = opts.plugin_default
		end
		if load == "auto" then
			if installed_plugins then
				load = installed_plugins[plugin] ~= nil
			else
				load = true
			end
		end

		if load then
			table.insert(plugins, module)
		end
	end

	return plugins
end

function M.get_module_highlights(colors, opts, module)
	local file_avail, file = pcall(require, module)
	if file_avail then
		if type(file) == "function" then
			return file(colors, opts.style)
		end
		return file
	end
end

function M.get_highlights(colors, opts)
	local highlights = {}
	for _, base in ipairs({
		"base",
		"syntax",
		"lsp",
		"treesitter",
		"heirline",
	}) do
		local module_highlights = M.get_module_highlights(colors, opts, "custom.theme.xnx-theme.groups." .. base)
		if module_highlights then
			highlights = vim.tbl_deep_extend("force", highlights, module_highlights)
		end
	end
	for _, plugin in ipairs(M.get_plugin_list(opts)) do
		local module_highlights =
			M.get_module_highlights(colors, opts, "custom.theme.xnx-theme.groups.plugins." .. plugin)
		if module_highlights then
			highlights = vim.tbl_deep_extend("force", highlights, module_highlights)
		end
	end

	return highlights
end

function M.set_highlights(highlights)
	for name, hl in pairs(highlights) do
		if type(hl) == "string" then
			hl = { link = hl }
		end
		vim.api.nvim_set_hl(0, name, hl)
	end
end

function M.set_terminal_colors(c)
	vim.g.terminal_color_0 = c.term.black
	vim.g.terminal_color_8 = c.term.bright_black
	vim.g.terminal_color_1 = c.term.red
	vim.g.terminal_color_9 = c.term.bright_red
	vim.g.terminal_color_2 = c.term.green
	vim.g.terminal_color_10 = c.term.bright_green
	vim.g.terminal_color_3 = c.term.yellow
	vim.g.terminal_color_11 = c.term.bright_yellow
	vim.g.terminal_color_4 = c.term.blue
	vim.g.terminal_color_12 = c.term.bright_blue
	vim.g.terminal_color_5 = c.term.purple
	vim.g.terminal_color_13 = c.term.bright_purple
	vim.g.terminal_color_6 = c.term.cyan
	vim.g.terminal_color_14 = c.term.bright_cyan
	vim.g.terminal_color_7 = c.term.white
	vim.g.terminal_color_15 = c.term.bright_white
	vim.g.terminal_color_background = c.term.background
	vim.g.terminal_color_foreground = c.term.foreground
end

return M
