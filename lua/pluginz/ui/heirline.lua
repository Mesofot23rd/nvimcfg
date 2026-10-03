return {
  {
    'rebelot/heirline.nvim',

    config = function()
      local components = require 'custom.statusline.init'
      local hl = require 'custom.statusline.hl'
      local heirline = require 'heirline'

      heirline.setup {
        statusline = components.STATUSLINE,
        tabline = components.TABLINE,
        statuscolumn = components.STATUSCOLUMN,
        opts = {
          colors = hl.get_colors(),
        },
      }
    end,
  },
}
