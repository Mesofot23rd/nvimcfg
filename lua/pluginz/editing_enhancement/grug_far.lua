return {
	-- search/replace in multiple files
	"MagicDuck/grug-far.nvim",
	cmd = "GrugFar",
	keys = {
		{ "<leader>sr", "<cmd>GrugFar<cr>", desc = "Search and Replace (grug-far)" },
		{ "<leader>sR", "<cmd>GrugFarWithin<cr>", desc = "Search and Replace in range" },
	},
	opts = {
		headerMaxWidth = 80,
		icons = { enabled = true },
	},
	config = function(_, opts) require("grug-far").setup(opts) end,
}
