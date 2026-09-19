return {
  'j-hui/fidget.nvim',
  lazy = false,
  config = function()
    local fidget = require 'fidget'
    fidget.setup {
      notification = {
        override_vim_notify = true, -- Redirect vim.notify to fidget manually
      },
    }

    local original_notify = vim.notify
    vim.notify = function(msg, level, opts)
      if level == vim.log.levels.ERROR then
        original_notify(msg, level, opts)
      else
        fidget.notify(msg, level, opts)
      end
    end
  end,
}
