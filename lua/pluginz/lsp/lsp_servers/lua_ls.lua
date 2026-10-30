return {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', 'stylua.toml' },
    settings = {
        Lua = {
            completion = {
                callSnippet = 'Replace',
            },
            runtime = { version = 'LuaJIT' },
            workspace = {
                checkThirdParty = false,
                library = vim.api.nvim_get_runtime_file('', true),
            },
            diagnostics = {
                globals = { 'vim' },
                disable = { 'missing-fields' },
            },
            format = {
                enable = false,
            },
        },
    },
}
