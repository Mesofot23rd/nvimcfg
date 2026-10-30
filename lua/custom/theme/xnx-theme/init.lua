local M = {}

local util = require("custom.theme.xnx-theme.lib.util")

M.config = {
	palette = "xnxdark",
	termguicolors = true,
	terminal_colors = true,
	style = {
		transparent = false,
		inactive = true,
		float = true,
		neotree = true,
		border = true,
		title_invert = false,
		italic_comments = true,
		simple_syntax_colors = false,
	},
	plugin_default = "auto",
	plugins = {},
}

function M.load()
	vim.o.background = "dark"
	util.reload(M.config)

	local colors = require("custom.theme.xnx-theme.palettes.xnxdark")
	local highlights = util.get_highlights(colors, M.config)

	util.set_highlights(highlights)

	if M.config.terminal_colors then
		util.set_terminal_colors(colors)
	end
end

return M
