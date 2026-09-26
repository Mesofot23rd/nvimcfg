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
    grace_period = (60 * 15),
    wakeup_delay = 3000,
    notifications = false,
    retries = 3,
    timeout = 1000,
  },
}
