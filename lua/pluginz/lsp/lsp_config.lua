return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "hrsh7th/cmp-nvim-lsp" },
	},

	config = function()
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities.textDocument.foldingRange = {
			dynamicRegistration = false,
			lineFoldingOnly = true,
		}

		local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
		if has_cmp then capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities()) end

		-- local capabilities = require('cmp_nvim_lsp').default_capabilities()

		local on_attach = function(_, bufnr)
			local function map(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "LSP: " .. desc })
			end

			map("n", "gd", vim.lsp.buf.type_definition, "[G]oto [D]definition")
			map("n", "gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
			map("n", "gr", vim.lsp.buf.references, "[r]oto [R]eferences")
			map("n", "gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")

			map("n", "<leader>lD", vim.lsp.buf.type_definition, "Type [D]definition")
			map("n", "<leader>lr", vim.lsp.buf.rename, "[R]e[n]ame")
			map("n", "<leader>lr", vim.lsp.buf.rename, "[R]e[n]ame")
			map("n", "<leader>la", vim.lsp.buf.code_action, "[A]ction")
			map("n", "<leader>lh", vim.lsp.buf.hover, "Hover Documentation")

			-- Navigate between document symbols with { and }
			local symbol_cache = { tick = nil, items = {} }

			--- Fetch (or reuse) the document symbols for this buffer.
			---@param callback fun(items: table[]?)
			local function get_symbols(callback)
				local tick = vim.b[bufnr].changedtick
				if symbol_cache.tick == tick then return callback(symbol_cache.items) end

				local client = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/documentSymbol" })[1]
				if not client then return callback(nil) end

				client:request("textDocument/documentSymbol", {
					textDocument = vim.lsp.util.make_text_document_params(bufnr),
				}, function(err, result)
					if err or not result then return callback(nil) end

					local items = vim.lsp.util.symbols_to_items(result, bufnr, client.offset_encoding)
					local bufname = vim.api.nvim_buf_get_name(bufnr)

					-- Keep this buffer's symbols, de-duplicate shared start positions and sort.
					local seen, positions = {}, {}
					for _, item in ipairs(items) do
						if item.filename == bufname then
							local position = { item.lnum, (item.col or 1) - 1 }
							local key = position[1] .. ":" .. position[2]
							if not seen[key] then
								seen[key] = true
								positions[#positions + 1] = position
							end
						end
					end
					table.sort(positions, function(a, b) return a[1] < b[1] or (a[1] == b[1] and a[2] < b[2]) end)

					symbol_cache = { tick = tick, items = positions }
					callback(positions)
				end, bufnr)
			end

			--- Jump to the previous/next document symbol.
			---@param forward boolean
			local function goto_symbol(forward)
				local win = vim.api.nvim_get_current_win()
				local cursor = vim.api.nvim_win_get_cursor(win)
				local count = math.max(vim.v.count1, 1)

				get_symbols(function(positions)
					-- The buffer may have changed while the request was in flight.
					if not positions or #positions == 0 or vim.api.nvim_get_current_buf() ~= bufnr then return end

					local target
					if forward then
						local index
						for i, position in ipairs(positions) do
							local after = position[1] > cursor[1] or (position[1] == cursor[1] and position[2] > cursor[2])
							if after then
								index = i
								break
							end
						end
						if not index then
							vim.notify("No next document symbol", vim.log.levels.INFO)
							return
						end
						target = positions[math.min(index + count - 1, #positions)]
					else
						local index
						for i = #positions, 1, -1 do
							local position = positions[i]
							local before = position[1] < cursor[1] or (position[1] == cursor[1] and position[2] < cursor[2])
							if before then
								index = i
								break
							end
						end
						if not index then
							vim.notify("No previous document symbol", vim.log.levels.INFO)
							return
						end
						target = positions[math.max(index - count + 1, 1)]
					end

					vim.cmd "normal! m'"
					vim.api.nvim_win_set_cursor(win, target)
				end)
			end

			map("n", "}", function() goto_symbol(true) end, "Next document symbol")
			map("n", "{", function() goto_symbol(false) end, "Previous document symbol")
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
