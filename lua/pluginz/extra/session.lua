return {
  'folke/persistence.nvim',
  -- The plugin is loaded once the UI is attached, so its module is always on the
  -- runtimepath by the time the keymaps below (or the autocmd in `init`) are used.
  --
  -- IMPORTANT: while this file is being read by lazy.nvim, the plugin is not on the
  -- runtimepath yet (its spec has not even been registered), so `require('persistence')`
  -- must NEVER run at the top level of this spec. Only inside `init`, `config` or a
  -- keymap callback, which all run after the plugin got loaded.
  event = 'UIEnter',
  opts = {
    dir = vim.fn.stdpath 'state' .. '/sessions/', -- directory where session files are saved
  },
  -- Auto restore the last session when nvim is started without a file.
  -- `VimEnter` (and not `UIEnter`) is used on purpose: `init` runs while the `UIEnter`
  -- event is being processed, and autocmds created during an event do not run for it.
  init = function()
    vim.api.nvim_create_autocmd('VimEnter', {
      once = true,
      callback = function()
        if #vim.fn.argv() == 0 then require('persistence').load() end
      end,
    })
  end,
  keys = {
    -- load the session for the current directory
    { '<leader>ss', function() require('persistence').load() end, desc = 'Load Session For Curr Dir' },
    -- select a session to load
    { '<leader>sS', function() require('persistence').select() end, desc = 'Session Load' },
    -- load the last session
    { '<leader>sl', function() require('persistence').load { last = true } end, desc = 'Load last Session' },
    -- stop Persistence => session won't be saved on exit
    { '<leader>sd', function() require('persistence').stop() end, desc = 'Stop Session Save' },
  },
}
