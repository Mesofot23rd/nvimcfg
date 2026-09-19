return {
  -- Hints keybinds
  'folke/which-key.nvim',
  event = 'VeryLazy',

  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    spec = {
      -- { '<leader>a', group = '[A]I' },
      { '<leader>b', group = '[B]uffer' },
      -- { '<leader>c', group = '[C]make' },
      -- { '<leader>d', group = '[D]iagnostics' },
      -- { '<leader>E', group = '[N]eo_Tree' },
      { '<leader>f', group = '[F]ind' },
      { '<leader>g', group = '[G]it' },
      { '<leader>l', group = '[L]sp/Language_Tools' },
      -- { '<leader>p', group = '[P]roject' },

      { '<leader>r', group = '[R]unCode' },
      { '<leader>R', group = '[R]unHtml' },

      -- { '<leader>S', group = '[S]ession' },
      -- { '<leader>t', group = '[T]erminal' },
      { '<leader>u', group = '[U]I/UX' },
      { '<leader>w', group = '[W]indow' },

      { '<leader>x', group = '[Q]uickFix' },
    },
    preset = 'helix', -- | "classic" | "modern" | "helix"
    notify = true, -- disable warnings for mappings
    win = {
      wo = {
        winblend = 15,
      },
    },
    -- expand = 3, -- expand groups when <= n mappings
  },

  config = function(_, opts)
    local wk = require 'which-key'
    wk.setup(opts)
    wk.add(opts.spec)
  end,
}
