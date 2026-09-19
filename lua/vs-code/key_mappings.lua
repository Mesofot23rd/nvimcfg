local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

local vscode = require 'vscode'

-- VS Code Neovim specific mappings
if vim.g.vscode then
  -- Notify VS Code for some actions
  map('n', '<leader>f', "<cmd>call VSCodeNotify('workbench.action.quickOpen')<cr>", { desc = 'Quick open' })
  map('n', '<leader>w', "<cmd>call VSCodeNotify('workbench.action.files.save')<cr>", { desc = 'Save file' })
  map('n', '<leader>p', "<cmd>call VSCodeNotify('workbench.action.showCommands')<cr>", { desc = 'Show commands' })

  map({ 'n', 'i' }, '<C-b>', "<cmd>lua vscode.call('workbench.action.toggleSidebarVisibility')<cr>")
  map({ 'n', 'i' }, '<C-w>', "<cmd>lua vscode.call('workbench.action.closeActiveEditor')<cr>")
end
