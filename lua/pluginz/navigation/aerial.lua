return {
	"stevearc/aerial.nvim",

	-- Optional dependencies
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons", --for file Icons
	},
	----------------------------------------------------------------------------------------------------------------
	--MAPPINGS

	keys = {
		{ "<leader>xa", "<Cmd>AerialNavToggle<CR>", desc = "Toggle Aerial" },
	},

	config = function()
		require("aerial").setup {
			-- optionally use on_attach to set keymaps when aerial has attached to a buffer
			on_attach = function(bufnr)
				-- Jump forwards/backwards with '{' and '}'
				vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
				vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
			end,
			filter_kind = false,
			layout = {
				max_width = { 40, 0.3 },
				width = nil,
				min_width = 25,
				default_direction = "right",
				placement = "edge",
			},
		}
	end,
}
