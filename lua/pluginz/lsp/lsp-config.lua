return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'hrsh7th/cmp-nvim-lsp', enabled = not vim.g.vscode },
  },
  config = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    if not vim.g.vscode then
      local has_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
      if has_cmp then capabilities = vim.tbl_deep_extend('force', capabilities, cmp_lsp.default_capabilities()) end
    end

    -- local capabilities = require('cmp_nvim_lsp').default_capabilities()

    local on_attach = function(_, bufnr)
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = 'LSP: ' .. desc })
      end

      if vim.g.vscode then
        map('n', 'gd', "<cmd>call VSCodeNotify('editor.action.revealDefinition')<cr>", '[G]oto [D]efinition')
        map('n', 'gr', "<cmd>call VSCodeNotify('editor.action.goToReferences')<cr>", '[G]oto [R]eferences')
        map('n', 'gI', "<cmd>call VSCodeNotify('editor.action.goToImplementation')<cr>", '[G]oto [I]mplementation')
        map('n', '<leader>lD', "<cmd>call VSCodeNotify('editor.action.goToTypeDefinition')<cr>", 'Type [D]efinition')
        map('n', '<leader>ls', "<cmd>call VSCodeNotify('workbench.action.gotoSymbol')<cr>", '[D]ocument [S]ymbols')
        map('n', '<leader>lw', "<cmd>call VSCodeNotify('workbench.action.showAllSymbols')<cr>", '[W]orkspace [S]ymbols')

        map('n', '<leader>lr', "<cmd>call VSCodeNotify('editor.action.rename')<cr>", '[R]e[n]ame')
        map('n', '<leader>la', "<cmd>call VSCodeNotify('editor.action.quickFix')<cr>", '[C]ode [A]ction')

        map('n', 'K', "<cmd>call VSCodeNotify('editor.action.showHover')<cr>", 'Hover Documentation')
        map('n', 'gD', "<cmd>call VSCodeNotify('editor.action.revealDeclaration')<cr>", '[G]oto [D]eclaration')
      else
        map('n', 'gd', vim.lsp.buf.type_definition, '[G]oto [D]efinition')
        map('n', 'gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        map('n', 'gr', vim.lsp.buf.references, '[G]oto [R]eferences')
        map('n', 'gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')

        map('n', '<leader>lD', vim.lsp.buf.type_definition, 'Type [D]efinition')
        map('n', '<leader>lr', vim.lsp.buf.rename, '[R]e[n]ame')
        map('n', '<leader>lr', vim.lsp.buf.rename, '[R]e[n]ame')
        map('n', '<leader>la', vim.lsp.buf.code_action, '[A]ction')
        map('n', '<leader>lh', vim.lsp.buf.hover, 'Hover Documentation')
      end
    end

    -- List of servers to setup (following prompt.txt table)
    local servers = {
      'autotools_ls', -- 'autotools-language-server'[config,automake,make],
      'biome', --['astro','css','graphql','html','javascript','javascriptreact','json','jsonc','svelte','typescript','typescriptreact','vue',]
      -- 'bashls', --bash-language-server',
      -- 'clangd' --[ 'c', 'c.doxygen', 'cpp', 'cpp.doxygen', 'objc', 'objcpp', 'cuda']
      'cssls', -- 'vscode-css-language-server',
      'cmake', -- 'cmake-language-server',
      -- 'denols', -- [ javascript, typescript ]
      'html', -- 'vscode-html-language-server',
      'jsonls', -- 'vscode-json-language-server'
      -- 'lua_ls', -- 'lua-language-server',
      'marksman', --[markdown]
      'meson', -- 'muon-meson'[meson]
      'pyright', -- 'pyright-langserver',
      'rust_analyzer', --[rust]
      'systemd-lsp',
      'tombi', --[toml]
      'ts_ls', -- 'typescript-language-server',['javascript','javascriptreact','typescript','typescriptreact'],
      'vimls', --vim-language-server',
      'yamlls', -- 'yaml-language-server',
      -- 'java_language_server',
      -- 'kotlin_language_server',

      ---- Custom Lsp Configs ----
      'lua-ls', --[lua],
      'clang', --[c,c++]
      'bash-ls', --[bash,sh,zsh]

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
      local has_custom_opts, custom_opts = pcall(require, 'pluginz.lsp.lsp_servers.' .. server)
      if has_custom_opts then
        if type(custom_opts) == 'table' then
          local custom_on_attach = custom_opts.on_attach
          if custom_on_attach then
            opts.on_attach = function(client, bufnr)
              on_attach(client, bufnr)
              custom_on_attach(client, bufnr)
            end
            custom_opts.on_attach = nil
          end
          opts = vim.tbl_deep_extend('force', opts, custom_opts)
        elseif type(custom_opts) == 'function' then
          opts = custom_opts(opts) or opts
        end
      end

      vim.lsp.config(lsp_name, opts)
      vim.lsp.enable(server)
    end
  end,
}
