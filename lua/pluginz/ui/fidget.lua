return {
  'j-hui/fidget.nvim',
  lazy = false,
  config = function()
    local fidget = require 'fidget'
    fidget.setup {
      notification = {
        override_vim_notify = true, -- Redirect vim.notify to fidget manually

        override_vim_notify = true, -- Automatically override vim.notify() with Fidget
        filter = vim.log.levels.WARN, -- Minimum notifications level
      },
      logger = {
        level = vim.log.levels.ERROR, -- Minimum logging level
      },
    }
  end,
}
