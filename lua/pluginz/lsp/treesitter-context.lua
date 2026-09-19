return {
  'nvim-treesitter/nvim-treesitter-context',
  event = 'BufReadPost',
  opts = {
    mode = 'cursor',
    max_lines = 3.,
  },
}

