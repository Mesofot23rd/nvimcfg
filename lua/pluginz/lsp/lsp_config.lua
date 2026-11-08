return {
	"neovim/nvim-lspconfig",

	config = function()
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities.textDocument.foldingRange = {
			dynamicRegistration = false,
			lineFoldingOnly = true,
		}

		local on_attach = function(_, bufnr)
			local function map(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "LSP: " .. desc })
			end

			map("n", "<leader>ld", vim.lsp.buf.type_definition, "definition")
			map("n", "<leader>lD", vim.lsp.buf.declaration, "Declaration")
			map("n", "<leader>lR", vim.lsp.buf.references, "References")
			map("n", "<leader>lI", vim.lsp.buf.implementation, "Implementation")
			map("n", "<leader>lr", vim.lsp.buf.rename, "Rename")
			map("n", "<leader>la", vim.lsp.buf.code_action, "Action")
			map("n", "<leader>lh", vim.lsp.buf.hover, "Hover Documentation")
		end

		-- List of servers to setup (following prompt.txt table)
		local servers = {
			"autotools_ls", -- 'autotools-language-server'[config,automake,make],
			"biome", --['astro','css','graphql','html','javascript','javascriptreact','json','jsonc','svelte','typescript','typescriptreact','vue',]
			-- 'bashls', --bash-language-server',
			-- 'clangd' --[ 'c', 'c.doxygen', 'cpp', 'cpp.doxygen', 'objc', 'objcpp', 'cuda']
			"cssls", -- 'vscode-css-language-server',
			"cmake", -- 'cmake-language-server',
			-- 'denols', -- [ javascript, typescript ]
			"html", -- 'vscode-html-language-server',
			"jsonls", -- 'vscode-json-language-server'
			-- 'lua_ls', -- 'lua-language-server',
			"marksman", --[markdown]
			"meson", -- 'muon-meson'[meson]
			"pyright", -- 'pyright-langserver',
			"rust_analyzer", --[rust]
			"systemd-lsp",
			"tombi", --[toml]
			"ts_ls", -- 'typescript-language-server',['javascript','javascriptreact','typescript','typescriptreact'],
			"vimls", --vim-language-server',
			"yamlls", -- 'yaml-language-server',
			-- 'java_language_server',
			-- 'kotlin_language_server',

			---- Custom Lsp Configs ----
			"lua_ls", --[lua],
			"clang", --[c,c++]
			"bash_ls", --[bash,sh,zsh]

			-- 'mbake',
			-- 'cmake-ls',
		}

		for _, server in ipairs(servers) do
			local lsp_name = server
			local opts = {
				capabilities = capabilities,
				on_attach = on_attach,
			}

			-- Look for custom config in Pluginz/LSP/lsp_servers/<server>.lua
			local has_custom_opts, custom_opts = pcall(require, "pluginz.lsp.lsp_servers." .. server)
			if has_custom_opts then
				if type(custom_opts) == "table" then
					local custom_on_attach = custom_opts.on_attach
					if custom_on_attach then
						opts.on_attach = function(client, bufnr)
							on_attach(client, bufnr)
							custom_on_attach(client, bufnr)
						end
						custom_opts.on_attach = nil
					end
					opts = vim.tbl_deep_extend("force", opts, custom_opts)
				elseif type(custom_opts) == "function" then
					opts = custom_opts(opts) or opts
				end
			end

			vim.lsp.config(lsp_name, opts)
			vim.lsp.enable(server)
		end
	end,
}
