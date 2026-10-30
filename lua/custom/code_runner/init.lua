local M = {}
--- ### Commands for compiler.nvim
-- This plugin displays tasks for compiling/running your current project
-- based on the filetype of the file you are currently editing.

local cmd = vim.api.nvim_create_user_command

M.send_interrupt = function()
  require('custom.code_runner.file_runner').send_interrupt()
end

M.setup = function()
  cmd('CompilerOpen', function() require('custom.code_runner.fzf').show() end, { desc = 'Open the compiler' })

  cmd(
    'CompilerRedo',
    function() require('custom.code_runner.utils').compiler_redo() end,
    { desc = 'Redo the last selected compiler option' }
  )

  cmd('CodeRunnerRun', function() require('custom.code_runner.file_runner').run() end, { desc = 'Run current file' })

  cmd('CodeRunnerInterrupt', function() M.send_interrupt() end, { desc = 'Interrupt running code' })

  ---Set up keybindings
  local opts = { noremap = true, silent = true, desc = 'CodeRunner' }

  vim.keymap.set('n', '<F5>', '<cmd>CompilerOpen<CR>')
  vim.keymap.set('n', '<F6>', '<cmd>CompilerRedo<CR>')

  vim.keymap.set(
    'n',
    '<leader>rc',
    function() require('custom.code_runner.file_runner').run() end,
    vim.tbl_extend('force', opts, { desc = 'Run file' })
  )

  vim.keymap.set(
    'n',
    '<leader>rp',
    function() require('custom.code_runner.fzf').show() end,
    vim.tbl_extend('force', opts, { desc = 'Run project' })
  )

  vim.keymap.set(
    'n',
    '<F2>',
    function() M.send_interrupt() end,
    vim.tbl_extend('force', opts, { desc = 'Interrupt execution' })
  )
end

return M
