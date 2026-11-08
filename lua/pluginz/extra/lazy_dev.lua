return {
	-- Configures LuaLS to support auto-completion and type checking
	-- while editing your Neovim configuration.
	"folke/lazydev.nvim",
	cmd = { "LazyDev" },
	ft = "lua",
	opts = {
		library = {
			-- See the configuration section for more details
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } }, -- Load luvit types when the `vim.uv` word is found
			{ path = "LazyVim", words = { "LazyVim" } },
			{ path = "snacks.nvim", words = { "Snacks" } },
			{ path = "lazy.nvim", words = { "LazyVim" } },
			{ path = "nvim-lspconfig", words = { "lspconfig.settings" } },
			"nvim-dap-ui",
		},
	},
}
