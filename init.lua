--
-- ███╗   ██║███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--------------------------------------------------------------------------------
-- NeoVim Configuration Entry Point
--------------------------------------------------------------------------------

local function load_source(source)
  local status_ok, error = pcall(require, source)
  if not status_ok then
    vim.api.nvim_echo({ { 'Failed to load ' .. source .. '\n\n' .. error } }, true, { err = true })
  end
end

local function load_sources(source_files)
  vim.loader.enable()
  for _, source in ipairs(source_files) do
    load_source(source)
  end
end

local function load_sources_async(source_files)
  for _, source in ipairs(source_files) do
    vim.defer_fn(function() load_source(source) end, 50)
  end
end


-- Call the functions defined above.
load_sources {
  'base.options', --basic neovim configuration
  'base.auto_commands',
  'base.mappings', --Loads Global Key_Mappings
  'base.diagnostics', --Loads diagnostics related settings
}

-- Load Lazy setup (will handle conditional plugin loading)
load_sources_async { 'base.lazy_setup' }

-- Auto-check for config updates on startup (like Lazy.nvim checker)
vim.defer_fn(function()
  require('custom.config_update').autocheck()
end, 1000)
