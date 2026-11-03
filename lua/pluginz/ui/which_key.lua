return {

	-- which-key helps you remember key bindings by showing a popup
	-- with the active keybindings of the command you started typing.

	"folke/which-key.nvim",
	event = "VeryLazy",

	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	opts = {
		-- Document existing key chains
		spec = {
			{ "<leader>a", group = "[A]I", icon = { icon = require("custom.icons").Copilot } },
			{ "<leader>b", group = "[B]buffer", icon = { icon = require("custom.icons").Buffer } },
			-- { '<leader>c', group = '[C]make' },
			-- { '<leader>d', group = '[D]iagnostics' },

			{ "<leader>f", group = "[F]ind", icon = { icon = require("custom.icons").Find } },
			{ "<leader>g", group = "[G]it", icon = { icon = require("custom.icons").Git } },
			{ "<leader>l", group = "[L]sp/Language_Tools", icon = { icon = require("custom.icons").LSP } },
			{ "<leader>m", group = "[M]anager" },
			{ "<leader>r", group = "[R]unCode", icon = { icon = require("custom.icons").Run } },
			{ "<leader>rw", group = "[R]eplace", icon = { icon = require("custom.icons").Find } },

			{ "<leader>S", group = "[S]earch", icon = { icon = require("custom.icons").Search } },
			{ "<leader>t", group = "[T]erminal", icon = { icon = require("custom.icons").Terminal } },
			{ "<leader>u", group = "[U]I/UX", icon = { icon = require("custom.icons").UI } },
			{ "<leader>w", group = "[W]indow", icon = { icon = require("custom.icons").Window } },

			{ "<leader>x", group = "[Q]uickFix" },
			{ "[", group = "prev" },
			{ "]", group = "next" },
			{ "g", group = "goto" },
			{ "z", group = "fold" },
		},

		preset = "helix", -- | "classic" | "modern" | "helix"
		notify = true, -- disable warnings for mappings
		win = {
			wo = {
				winblend = 15,
			},
		},
		-- expand = 3, -- expand groups when <= n mappings
	},

	config = function(_, opts)
		local wk = require "which-key"
		wk.setup(opts)
		wk.add(opts.spec)
	end,
}
