return {
  'lukas-reineke/indent-blankline.nvim',
  -- event = 'User FilePost',
  -- enabled = false,
  cond = not vim.g.vscode,
  opts = {},

  config = function()
    require('ibl').setup {
      indent = { highlight = highlight, char = '▏' },
      whitespace = {
        highlight = highlight,
        remove_blankline_trail = false,
      },
      scope = { enabled = true },
    }
  end,
}
