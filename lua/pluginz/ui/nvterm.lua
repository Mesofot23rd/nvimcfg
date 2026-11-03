return {
	"NvChad/nvterm",
	keys = {
		-- open in a specific direction (normal mode)
		{ "<leader>tf", function() require("nvterm.terminal").toggle "float" end, desc = "Open Floating Terminal" },
		{ "<leader>th", function() require("nvterm.terminal").toggle "horizontal" end, desc = "Open Horizontal Terminal" },
		{ "<leader>tv", function() require("nvterm.terminal").toggle "vertical" end, desc = "Open Vertical Terminal" },

		-- toggle the default terminal
		{
			"<F7>",
			function() require("nvterm.terminal").toggle "vertical" end,
			desc = "Toggle terminal",
			mode = { "i", "t", "n" },
		},

		-- <C-'> requires a terminal that lets the sequence through
		{
			"<C-'>",
			function() require("nvterm.terminal").toggle "vertical" end,
			desc = "Toggle terminal",
			mode = { "i", "t", "n" },
		},
	},
	config = function()
		require("nvterm").setup {
			terminals = {
				shell = vim.o.shell,
				list = {},
				type_opts = {
					float = {
						relative = "editor",
						row = 0.7,
						col = 0.5,
						width = 0.7,
						height = 0.5,
						border = "single",
					},
					horizontal = { location = "rightbelow", split_ratio = 0.3 },
					vertical = { location = "rightbelow", split_ratio = 0.4 },
				},
			},

			behavior = {
				autoclose_on_quit = {
					enabled = false,
					confirm = true,
				},
				close_on_exit = true,
				auto_insert = true,
			},
		}
	end,
}
