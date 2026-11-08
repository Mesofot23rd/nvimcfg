return {
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "BufReadPost",
		opts = {
			mode = "cursor",
			max_lines = 3.,
		},
	},

	{
		"nvim-treesitter/nvim-treesitter",
		event = "VeryLazy",

		lazy = false,
		build = ":TSUpdate",

		opts = {
			sync_install = true, -- Install parsers synchronously (only applied to `ensure_installed`)
			auto_install = true, -- Automatically install missing parsers when entering buffer

			ensure_installed = {
				-- Only install essential parsers by default
				"c",
				"cpp",
				"cmake",
				"make",
				"javascript",
				"typescript",
				"jsx",
				"tsx",
				"comment",
				"bash",
				"lua",
				"python",
				"html",
				"css",
				"xml",
				"json",
				"json5",
				"yaml",
				"toml",
				"markdown",
				"markdown_inline",
				"vim",
				"vimdoc",
				"query",
				"diff",
				"gitcommit",
				"gitignore",
			},
			indent = {
				enable = true,
			},
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
				disable = function(_, buf)
					local max_filesize = 500 * 1024 -- 500 KB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then return true end
				end,
			},

			matchup = {
				enable = true,
				enable_quotes = true,
				disable = function(_, buf)
					local max_filesize = 1000 * 1024 -- 1 MB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then return true end
				end,
			},
			incremental_selection = { enable = true },
		},

		config = function(_, opts)
			require("nvim-treesitter").setup(opts)

			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "rust", "javascript", "typescript", "jsx", "tsx", "lua", "python" },
				callback = function() vim.treesitter.start() end,
			})
		end,
	},
}
