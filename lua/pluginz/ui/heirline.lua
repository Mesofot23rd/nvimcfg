return {
  {
    'rebelot/heirline.nvim',
    enabled = true,
    config = function()
      local components = require 'custom.statusline_components.init'
      local hl = require 'custom.statusline_components.hl'
      local heirline = require 'heirline'

      heirline.setup {
        statusline = components.STATUSLINE,
        tabline = components.TABLINE,
        statuscolumn = components.STATUSCOLUMN,
        opts = {
          colors = hl.get_colors(),
        },
      }

      -- Update colors on colorscheme change
      vim.api.nvim_create_autocmd({ 'ColorScheme', 'UIEnter' }, {
        callback = function()
          require('heirline.utils').on_colorscheme(hl.get_colors())
        end,
      })
    end,
  },
}
