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

-- Call the functions defined above.
load_sources {
  'base.options', --basic neovim configuration
  'base.auto_commands',
  'base.mappings', --global key mappings (plugin specific mappings are within plugin configuration)
  'base.diagnostics', --Loads diagnostics related settings
  'base.lazy_setup', -- lazy bootstrap and configuration (handles conditional plugin loading)

  'custom.statusline', -- custom native statusline, winbar, tabline & statuscolumn
}

require('custom.code_runner').setup()
