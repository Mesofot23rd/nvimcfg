local M = {
	-- "mason-org/mason.nvim",
	"williamboman/mason.nvim",
	dependencies = {
		-- "mason-org/mason-lspconfig.nvim",
		"williamboman/mason-lspconfig.nvim",
	},
}

function M.config()
	local servers = {
		"lua_ls",
		"cssls",
		"html",
		"ts_ls",
		"pyright",
		"bashls",
		"jsonls",
	}

	require("mason").setup {
		ui = {
			border = "rounded",
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
		},
		-- Ensure all language servers are available
		ensure_installed = {
			-- Core languages
			"lua-language-server",
			"pyright",
			"typescript-language-server",
			"javascript-language-server",
			"html-lsp",
			"css-lsp",
			"json-lsp",
			"yaml-language-server",
			"markdown-language-server",

			-- -- Additional languages
			-- "ruby-lsp",
			-- "gopls",
			-- "rust-analyzer",
			-- "jdtls",
			-- "clangd",
			-- "phpactor",
			-- "sqls",
			-- "dockerfile-language-server",
			-- "cmake-language-server",
			-- "vim-language-server",
			-- "bash-language-server",
			-- "powershell-editor-services",
			-- "zls",
			-- "nimlsp",
			-- "dart",
			-- "kotlin-language-server",
			-- "metals",
			-- "haskell-language-server",
			-- "ocaml-lsp",
			-- "fsautocomplete",
			-- "clojure-lsp",
			-- "elixir-ls",
			-- "erlang-ls",
			-- "perlnavigator",
			-- "r-lsp",
			-- "julia-lsp",
			-- "racket-langserver",
			-- "ada-language-server",
			-- "fortls",
			-- "cobol-language-support",
			-- "pascal-language-server",
			-- "verible",
			-- "vhdl-tool",
			-- "systemverilog",
			-- "tcl-lsp",
			-- "awk-language-server",
			-- "fish-lsp",
			"zsh-language-server",
			-- "terraform-ls",
			-- "nixd",
			-- "protolint",
			-- "pug-lsp",
			-- "rst-language-server",
			-- "solidity-ls",
			-- "svelte-language-server",
			-- "astro-language-server",
			-- "vue-language-server",
			-- "angular-language-service",
			-- "ember-language-server",
			-- "elm-language-server",
			-- "reason-language-server",
			-- "rescript-lsp",
			-- "gleam",
			-- "nickel-lang-lsp",
			-- "taplo",
			-- "wgsl-analyzer",
			-- "wgsl-analyzer",
			-- "wgsl-analyzer",
		},
	}
	require("mason-lspconfig").setup {
		ensure_installed = servers,
	}
end

return M
