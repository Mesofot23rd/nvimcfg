-- Highlight, list and search todo comments in your projects
-- https://github.com/folke/todo-comments.nvim
-- TODO: a todo
-- WARN: a warning
-- PERF: a performance remark
-- NOTE: a note
-- FIXME: a fixme

return {
    'folke/todo-comments.nvim',
    cond = not vim.g.vscode,
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        vim.keymap.set('n', ']t', function()
            require('todo-comments').jump_next()
        end, { desc = 'Next TODO' })

        vim.keymap.set('n', '[t', function()
            require('todo-comments').jump_prev()
        end, { desc = 'Previous TODO' })
    end,
}
