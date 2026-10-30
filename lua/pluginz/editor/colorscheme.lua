return {
  {
    'Luxed/ayu-vim',
    lazy = true,
  },
  {
    'projekt0n/github-nvim-theme',
    lazy = true,
  },
  {
    'navarasu/onedark.nvim',
    lazy = true,
    config = function()
      require('onedark').setup {
        style = 'darker',
      }
      require('onedark').load()
    end,
  },
}
