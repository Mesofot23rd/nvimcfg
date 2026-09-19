--Setup Lazy
local is_vscode = vim.g.vscode ~= nil
-- local is_android=vim.g.v

local specs

if is_vscode then
  specs = { { import = 'pluginz.lsp' } }
-- if is_android then
-- specs = {}
else
  specs = {
    { import = 'pluginz.lsp' },
    { import = 'pluginz.editor' },
    { import = 'pluginz.editing_enhancement' },
    { import = 'pluginz.dev' },
    { import = 'pluginz.extra' },
    { import = 'pluginz.lsp.auto-completion' },
    { import = 'pluginz.navigation' },
    { import = 'pluginz.ui' },
  }
end

require('lazy').setup {
  spec = specs,
  change_detection = {
    enabled = true, -- automatically check for config file changes and reload the UI
    notify = false, -- turn off notifications whenever plugin changes are made
  },
  install = {
    -- colorscheme that will be used when installing plugins.
    colorscheme = { vim.g.colors_name or 'xnxdark' or 'default' },
  },
  -- automatically check for plugin updates
  checker = { enabled = true },
  ui = {
    border = 'rounded',
    title = 'Plugin Manager',
    title_pos = 'center',
    size = {
      width = 0.9, -- optional: controls window size relative to screen
      height = 0.8,
    },
  },
}
