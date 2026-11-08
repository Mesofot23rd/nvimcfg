return {
	-- better diagnostics list and others

	"folke/trouble.nvim",
	cmd = "Trouble",
	keys = {

		-- { "}", require("trouble").next(), desc = "Next Trouble Item" },
		-- { "{", require("trouble").prev(), desc = "Prev Trouble Item" },

		{ "<leader>xD", "<Cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics" },
		{
			"<leader>xd",
			"<Cmd>Trouble diagnostics toggle filter.buf=0 <CR>",
			desc = "Buffer diagnostics",
		},
		{
			"<leader>xl",
			"<cmd>Trouble lsp toggle focus=false<cr>",
			desc = "LSP Definitions / references / ... (Trouble)",
		},
		{
			"<leader>xL",
			"<cmd>Trouble loclist toggle<cr>",
			desc = "Location List (Trouble)",
		},
		{
			"<leader>xQ",
			"<cmd>Trouble qflist toggle<cr>",
			desc = "Quickfix List (Trouble)",
		},
		{ "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
	},

	opts = {
		win = {
			type = "split",
			relative = "editor",
			border = "rounded",
			-- title = "Preview",
			title_pos = "center",
			position = "right",
			size = 0.4,
			-- zindex = 200,
		},

		auto_close = true, -- auto close when there are no items
		auto_open = false, -- auto open when there are items
		auto_preview = true, -- automatically open preview when on an it
	},
}
