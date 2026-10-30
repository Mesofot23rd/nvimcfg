return {
  'nvim-treesitter/nvim-treesitter-context',
  -- enabled = false,
  event = 'BufReadPost',
  opts = {
    mode = 'cursor',
    max_lines = 3.,
  },
}
