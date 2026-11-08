---@class XnxDarkPalette
local c = {
	none = "NONE",
	syntax = {},
	ui = {},
	term = {},
	icon = {},
}

--------------------------------
--- Syntax
--------------------------------
c.syntax.red = "#FF838B"
c.syntax.orange = "#F5983A"
c.syntax.yellow = "#DFAB25"
c.syntax.green = "#87C05F"
c.syntax.cyan = "#4AC2B8"
c.syntax.blue = "#5EB7FF"
c.syntax.purple = "#DD97F1"
c.syntax.text = "#ADB0BB"
c.syntax.comment = "#696C76"
c.syntax.mute = "#595C66"

--------------------------------
--- UI
--------------------------------
c.ui.red = "#F8747E"
c.ui.orange = "#EB8332"
c.ui.yellow = "#D09214"
c.ui.green = "#75AD47"
c.ui.cyan = "#00B298"
c.ui.blue = "#50A4E9"
c.ui.purple = "#CC83E3"

c.ui.accent = "#50A4E9"

c.ui.tabline = "#111317"
c.ui.winbar = "#797D87"
c.ui.tool = "#03060B"
c.ui.base = "#07080D"
c.ui.inactive_base = "#0A0C10"

c.ui.statusline = "#111317"
c.ui.split = "#3A3E47"
c.ui.float = "#07080D"
c.ui.title = c.ui.accent
c.ui.border = "#3A3E47"
c.ui.current_line = "#1E222A"
c.ui.scrollbar = c.ui.accent
c.ui.selection = "#26343F"
-- TODO: combine menu_selection and selection
c.ui.menu_selection = c.ui.selection
c.ui.highlight = "#23272F"
c.ui.none_text = "#3A3E47"
c.ui.text = "#9B9FA9"
c.ui.text_active = "#ADB0BB"
c.ui.text_inactive = "#494D56"
c.ui.text_match = "#E0E0Ee"

c.ui.prompt = "#21242A"

--------------------------------
--- terminal
--------------------------------
c.ui.tabline_light = "#281E22"
c.syntax.red_light = "#DF8489"
c.syntax.green_light = "#84A860"
c.syntax.yellow_light = "#C3963D"
c.syntax.blue_light = "#4FA9C6"
c.syntax.purple_light = "#CD87BA"
c.syntax.cyan_light = "#4FAD97"
c.syntax.orange_light = "#EF9474"
c.ui.text_light = "#8B7079"

c.term.black = c.ui.tabline
c.term.bright_black = c.ui.text_inactive

c.term.red = c.syntax.red
c.term.bright_red = c.syntax.red_light

c.term.green = c.syntax.green
c.term.bright_green = c.syntax.green_light

c.term.yellow = c.syntax.yellow
c.term.bright_yellow = c.syntax.yellow_light

c.term.blue = c.syntax.blue
c.term.bright_blue = c.syntax.blue_light

c.term.purple = c.syntax.purple
c.term.bright_purple = c.syntax.purple_light

c.term.cyan = c.syntax.cyan
c.term.bright_cyan = c.syntax.cyan_light

c.term.white = c.ui.text
c.term.bright_white = c.ui.text_light

c.term.background = c.ui.base
c.term.foreground = c.ui.text

--------------------------------
--- Icons
--------------------------------
c.icon.c = "#519aba"
c.icon.css = "#61afef"
c.icon.deb = "#a1b7ee"
c.icon.docker = "#384d54"
c.icon.html = "#de8c92"
c.icon.jpeg = "#c882e7"
c.icon.jpg = "#c882e7"
c.icon.js = "#ebcb8b"
c.icon.jsx = "#519ab8"
c.icon.kt = "#7bc99c"
c.icon.lock = "#c4c720"
c.icon.lua = "#51a0cf"
c.icon.mp3 = "#d39ede"
c.icon.mp4 = "#9ea3de"
c.icon.out = "#abb2bf"
c.icon.png = "#c882e7"
c.icon.py = "#a3b8ef"
c.icon.rb = "#ff75a0"
c.icon.robots = "#abb2bf"
c.icon.rpm = "#fca2aa"
c.icon.rs = "#dea584"
c.icon.toml = "#39bf39"
c.icon.ts = "#519aba"
c.icon.ttf = "#abb2bf"
c.icon.vue = "#7bc99c"
c.icon.woff = "#abb2bf"
c.icon.woff2 = "#abb2bf"
c.icon.zip = "#f9d71c"
c.icon.md = "#519aba"
c.icon.pkg = "#d39ede"

return c
