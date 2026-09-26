return {
  'folke/trouble.nvim',
  cmd = 'Trouble',
  keys = {
    { '<leader>xD', '<Cmd>Trouble diagnostics toggle win.position=right<CR>', desc = 'Diagnostics' },
    {
      '<leader>xd',
      '<Cmd>Trouble diagnostics toggle filter.buf=0 win.position=right<CR>',
      desc = 'Buffer diagnostics',
    },
    {
      '<leader>xl',
      '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
      desc = 'LSP Definitions / references / ... (Trouble)',
    },
    {
      '<leader>xL',
      '<cmd>Trouble loclist toggle win.position=right<cr>',
      desc = 'Location List (Trouble)',
    },
    {
      '<leader>xQ',
      '<cmd>Trouble qflist toggle win.position=right<cr>',
      desc = 'Quickfix List (Trouble)',
    },
  },
  opts = {
    win = {
      type = 'split',
      position = 'right',
    },
    auto_close = true, -- auto close when there are no items
    auto_open = true, -- auto open when there are items
    auto_preview = true, -- automatically open preview when on an it
  },
}
