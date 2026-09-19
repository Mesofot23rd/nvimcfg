--------------------------------------------------------------------------------
-- NeoVim Configuration Entry Point
--------------------------------------------------------------------------------

-- Set leader key early
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Lazy Installation
local lazypath = vim.env.LAZY or vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
	-- stylua: ignore
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
		lazypath })
end
vim.opt.rtp:prepend(lazypath)

if vim.g.vscode then --[LOAD_CONFIG FOR VSCODE]
  require 'vs-code.key_mappings'
  require 'config.diagnostics'
  require 'config.key_mappings'
else --[LOAD_CONFIG FOR LINUX]
  require 'config.options' --basic neovim configuration
  require 'config.key_mappings' --Loads Global Key_Mappings
  require 'config.diagnostics' --Loads diagnostics related settings
  require 'config.auto_commands'

  require 'config.user_commands'
  require('custom.code_runner.init').setup()
end

-- Load Lazy setup (will handle conditional plugin loading)
require 'config.lazy_setup'
