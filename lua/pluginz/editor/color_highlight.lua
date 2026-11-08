return {
	"brenoprata10/nvim-highlight-colors",
	lazy = "VeryLazy",
	config = function()
		require("nvim-highlight-colors").setup {

			render = "virtual", ---@usage 'background'|'foreground'|'virtual'
			virtual_symbol = "󰝤", --'■' ---Set virtual symbol (requires render to be set to 'virtual')
			-- virtual_symbol_prefix = "", ---Set virtual symbol suffix (defaults to '')
			-- virtual_symbol_suffix = " ", ---Set virtual symbol suffix (defaults to ' ')

			---Set virtual symbol position()
			---@usage 'inline'|'eol'|'eow'
			---inline mimics VS Code style
			---eol stands for `end of column` - Recommended to set `virtual_symbol_suffix = ''` when used.
			---eow stands for `end of word` - Recommended to set `virtual_symbol_prefix = ' ' and virtual_symbol_suffix = ''` when used.
			virtual_symbol_position = "inline",

			enable_hex = true, ---Highlight hex colors, e.g. '#FFFFFF'
			enable_short_hex = true, ---Highlight short hex colors e.g. '#fff'
			enable_rgb = true, ---Highlight rgb colors, e.g. 'rgb(0 0 0)'
			enable_hsl = true, ---Highlight hsl colors, e.g. 'hsl(150deg 30% 40%)'
			enable_ansi = true, ---Highlight ansi colors, e.g '\033[0;34m'
			enable_hsl_without_function = true, -- Highlight hsl colors without function, e.g. '--foreground: 0 69% 69%;'
			enable_var_usage = true, ---Highlight CSS variables, e.g. 'var(--testing-color)'
			enable_named_colors = true, ---Highlight named colors, e.g. 'green'
			enable_tailwind = false, ---Highlight tailwind colors, e.g. 'bg-blue-500'

			---Set custom colors
			---Label must be properly escaped with '%' to adhere to `string.gmatch`
			--- :help string.gmatch
			custom_colors = {
				{ label = "%-%-theme%-primary%-color", color = "#0f1219" },
				{ label = "%-%-theme%-secondary%-color", color = "#5a5d64" },
			},

			-- Exclude filetypes or buftypes from highlighting e.g. 'exclude_buftypes = {'text'}'
			exclude_filetypes = { "text" },
			exclude_buftypes = { "lazy" },
			-- Exclude buffer from highlighting e.g. 'exclude_buffer = function(bufnr) return vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr)) > 1000000 end'
			-- exclude_buffer = function(bufnr) end,
		}
	end,
}
