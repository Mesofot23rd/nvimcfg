return {
  'numToStr/Comment.nvim',
  event = 'VeryLazy',
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring',
  },
  keys = {
    {
      '<C-/>',
      -- defer the require: Comment.nvim is lazy loaded on VeryLazy
      function() require('Comment.api').toggle.linewise.current() end,
      mode = { 'n', 'i' },
      desc = 'Toggle Comment',
    },
    {
      '<C-/>',
      "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
      mode = { 'v' },
      desc = 'Toggle Comment (Visual)',
    },
  },

  config = function()
    require('Comment').setup {

      ignore = '^$',
      padding = true,
      sticky = false,
      --pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
    }

    local ft = require 'Comment.ft'
    ft.set('conf', '#%s')
    ft.set('env', '#%s')

    -- KEYMAP

    -- Set comment string for /etc/environment
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'conf' },
      callback = function() vim.opt_local.commentstring = '#%s' end,
    })
  end,
}
