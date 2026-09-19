return {
  'numToStr/Comment.nvim',

  cond = not vim.g.vscode,
  event = 'VeryLazy',
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring',
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

    vim.keymap.set({ 'n', 'i' }, '<C-_>', require('Comment.api').toggle.linewise.current)
    vim.keymap.set({ 'n', 'i' }, '<C-/>', require('Comment.api').toggle.linewise.current)
    vim.keymap.set('v', '<C-_>', "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>")
    vim.keymap.set('v', '<C-/>', "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>")

    -- Set comment string for /etc/environment
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'conf' },
      callback = function()
        vim.opt_local.commentstring = '#%s'
      end,
    })
  end,
}
