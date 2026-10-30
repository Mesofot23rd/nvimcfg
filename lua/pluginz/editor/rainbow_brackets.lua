return {
  --RAINBOW BRACKETS
  'HiPhish/rainbow-delimiters.nvim',

  cond = not vim.g.vscode,
  event = { 'BufReadPost', 'BufNewFile' }, -- Load the extension after your file content
  lazy = true,
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
}
