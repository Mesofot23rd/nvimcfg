return {
	"lukas-reineke/indent-blankline.nvim",
	-- event = 'User FilePost',
	-- enabled = false,

	opts = {},

	config = function()
		require("ibl").setup {
			indent = { char = "▏" },
			whitespace = {
				remove_blankline_trail = false,
			},
			scope = { enabled = true },
		}
	end,
}
