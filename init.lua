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
--
-- NOTE on the order (and on *not* deferring these requires):
--
--  * `base.options` has to come first: lazy.nvim reads `vim.g.mapleader` while
--    resolving the `<leader>` keys used by the plugin specs.
--  * Everything has to be loaded while this file is being sourced, i.e.
--    synchronously. Startup events (`VimEnter`, `UIEnter`, `BufReadPre`,
--    `BufReadPost`, ...) are dispatched before Neovim's event loop ever gets a
--    chance to run a `vim.defer_fn` callback, so deferring the lazy setup means
--    that, on a fresh start:
--      - `require('<plugin module>')` from an autocmd fails with
--        "module not found" (the plugin is not on the `runtimepath` yet and
--        lazy's `require` autoloader is not registered yet), and
--      - lazy never sees the `event = 'BufReadPre'|'BufReadPost'|'BufNewFile'|...`
--        triggers of the first file, so those plugins stay unloaded until you
--        open another buffer.
load_sources {
  'base.options', --basic neovim configuration
  'base.auto_commands',
  'base.mappings', --Loads Global Key_Mappings
  'base.diagnostics', --Loads diagnostics related settings
  'base.lazy_setup', --lazy.nvim setup (handles conditional plugin loading)
}
