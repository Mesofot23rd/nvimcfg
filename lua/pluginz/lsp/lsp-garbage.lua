--  garbage-day.nvim [lsp garbage collector]
--  https://github.com/zeioth/garbage-day.nvim
return {
  'zeioth/garbage-day.nvim',
  event = 'User BaseFile',
  opts = {
    aggressive_mode = false,
    excluded_lsp_clients = {
      'null-ls',
      'jdtls',
      'marksman',
      'lua_ls',
    },
    grace_period = (60 * 5),
    wakeup_delay = 3000,
    notifications = true,
    retries = 3,
    timeout = 1000,
  },

  vim.keymap.set(
    'n',
    '<leader>lS',
    function() require('garbage-day.utils').stop_lsp() end,
    { desc = 'Stop All LSP servers' }
  ),
  vim.keymap.set(
    'n',
    '<leader>ls',
    function() require('garbage-day.utils').start_lsp() end,
    { desc = 'Start LSP Server for current buffer' }
  ),
}
