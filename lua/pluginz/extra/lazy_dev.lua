return {
	-- Configures LuaLS to support auto-completion and type checking
	-- while editing your Neovim configuration.
	"folke/lazydev.nvim",
	cmd = { "LazyDev" },
	ft = "lua", -- only load on lua files
	opts = {
		library = {
			-- See the configuration section for more details
			-- Load luvit types when the `vim.uv` word is found
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			{ path = "LazyVim", words = { "LazyVim" } },
			{ path = "snacks.nvim", words = { "Snacks" } },
			{ path = "lazy.nvim", words = { "LazyVim" } },
			{ path = "nvim-lspconfig", words = { "lspconfig.settings" } },
			"nvim-dap-ui",
		},
	},
}
