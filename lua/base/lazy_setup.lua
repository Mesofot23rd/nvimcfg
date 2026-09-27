local is_vscode = vim.g.vscode ~= nil
local is_android = vim.fn.has 'Android'
-- local is_windows = vim.fn.has 'Win32'

---------------------------------------------------------------------------------
-- Lazy Installation
---------------------------------------------------------------------------------
local lazypath = vim.env.LAZY or vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
	-- stylua: ignore
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
		lazypath })
end
vim.opt.rtp:prepend(lazypath)

---------------------------------------------------------------------------------
-- Conditional plugin loading
---------------------------------------------------------------------------------
local specs

--plugins to load when using neovim inside vscode
if is_vscode then
  specs = { { import = 'pluginz.lsp' } }

-- plugins to load when using neovim on android
elseif is_android == 1 then
  specs = {
    { import = 'pluginz.dev.git' },

    { import = 'pluginz.editor.indent_line' },
    { import = 'pluginz.editor.rainbow_brackets' },
    { import = 'pluginz.editor.todo_comments' },

    { import = 'pluginz.editing_enhancement' },
    { import = 'pluginz.dev' },
    { import = 'pluginz.extra' },
    { import = 'pluginz.lsp' },
    { import = 'pluginz.navigation' },
    { import = 'pluginz.ui' },
  }

--plugins to load when using neovim on PC
else
  specs = {
    { import = 'pluginz.dev' },
    { import = 'pluginz.editor' },
    { import = 'pluginz.editing_enhancement' },
    { import = 'pluginz.extra' },
    { import = 'pluginz.lsp' },
    { import = 'pluginz.navigation' },
    { import = 'pluginz.ui' },
  }
end

---------------------------------------------------------------------------------
-- Lazy Setup
---------------------------------------------------------------------------------
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
  performance = {
    rtp = { -- Disable unnecessary nvim features to speed up startup.
      disabled_plugins = {
        'tohtml',
        'gzip',
        'zipPlugin',
        'netrwPlugin',
        'tarPlugin',
      },
    },
  },
  -- Enable luarocks if installed.
  rocks = { enabled = vim.fn.executable 'luarocks' == 1 },
}
