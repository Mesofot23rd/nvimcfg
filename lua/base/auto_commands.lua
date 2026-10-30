local autocmd = vim.api.nvim_create_autocmd

--- augroup helper function ----------------------------------------------------

local function augroup(name, opts)
  opts = opts or { clear = true }
  return vim.api.nvim_create_augroup('scratch_' .. name, opts)
end

---------------------------------------------------------------------------------
---- MAKE SPECIAL BUFFERS "UNLISTED" AND PREVENT THEM FROM BEING REPLACED:
---------------------------------------------------------------------------------
autocmd('BufEnter', {
  pattern = { 'term://*', 'qf', 'help', 'oil://*', 'copilot-*', 'man' },
  callback = function()
    vim.bo.buflisted = false
    vim.bo.bufhidden = 'hide'
  end,
})

---------------------------------------------------------------------------------
---- RESTORE_CURSOR  go to last loc when opening a buffer
---------------------------------------------------------------------------------
autocmd('BufReadPost', {
  callback = function(args)
    local buf = args.buf
    if vim.b[buf].last_loc_restored or vim.tbl_contains({ 'gitcommit' }, vim.bo[buf].filetype) then return end
    vim.b[buf].last_loc_restored = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(buf) then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

---------------------------------------------------------------------------------
----SESSION AND COLORSCHEME RESTORE
--------------------------------------------------------------------------------
autocmd('UIEnter', {
  callback = function()
    require('custom.colorscheme_persist').load()
    require('custom.bg_change').load_bg()
  end,
})

---------------------------------------------------------------------------------
----SAVE COLORSCHEME TO FiLE ON WHEN COLORSCHEME IS CHANGED\
----RE-APPLY BACKGROUND COLOR ON COLORSCHEME CHANGE
---------------------------------------------------------------------------------
autocmd('ColorScheme', {
  callback = function()
    -- require('custom.colorscheme_persist').save_colorscheme(vim.g.colors_name)
    require('custom.bg_change').load_bg()
  end,
})

---------------------------------------------------------------------------------
---- HELP WINDOW LEFT
---------------------------------------------------------------------------------
-- autocmd('FileType', {
--   pattern = 'help',
--   callback = function() vim.cmd 'wincmd L' end,
-- })

---------------------------------------------------------------------------------
---- CLOSE THE FOLLOWING PATTERN WITH `Q`
---------------------------------------------------------------------------------
autocmd('FileType', {
  pattern = {
    'checkhealth',
    'qf',
    'help',
    'man',
    'lspinfo',
    'PlenaryTestPopup',
    'checkhealth',
    'dap-float',
    'dbout',
    'gitsigns-blame',
    'grug-far',
    'help',
    'lspinfo',
    'neotest-output',
    'neotest-output-panel',
    'neotest-summary',
    'notify',
    'qf',
    'spectre_panel',
    'startuptime',
    'tsplayground',
  },
  callback = function() vim.keymap.set('n', 'q', ':close<CR>', { noremap = true, silent = true }) end,
})

---------------------------------------------------------------------------------
---- EXCLUDE SPECIAL BUFFERS FROM SESSION
---------------------------------------------------------------------------------
-- autocmd('User', {
--   pattern = 'PersistenceSavePre',
--   callback = function()
--     for _, win in ipairs(vim.api.nvim_list_wins()) do
--       local buf = vim.api.nvim_win_get_buf(win)

--       -- local buftype = vim.api.nvim_get_option_value('buftype', { buf = 0 })
--       -- return buftype == 'terminal'

--       local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
--       local ft_exclude =
--         { 'neo-tree', 'aerial', 'trouble', 'qf', 'help', 'lazy', 'man', 'lspinfo', 'notify', 'terminal' }
--       if vim.tbl_contains(ft_exclude, ft) then vim.api.nvim_win_close(win, true) end
--     end
--   end,
-- })

---------------------------------------------------------------------------------
---- C/C++ HEADER TOGGLE
---------------------------------------------------------------------------------
autocmd('FileType', {
  pattern = { 'c', 'cpp' },
  callback = function()
    vim.keymap.set(
      'n',
      'T',
      function() require('custom.header_switch').toggle() end,
      { buffer = true, desc = 'Toggle between header and implementation files' }
    )
  end,
})

---------------------------------------------------------------------------------
---- DISABLE AUTO-COMMENT ON NEW LINE
---------------------------------------------------------------------------------
-- autocmd('FileType', {
--   pattern = '*',
--   callback = function() vim.opt_local.formatoptions:remove { 'r', 'o' } end,
-- })

---------------------------------------------------------------------------------
----  wrap and check for spell in text filetypes
---------------------------------------------------------------------------------
-- vim.api.nvim_create_autocmd('FileType', {
--   group = augroup 'wrap_spell',
--   pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
--   callback = function()
--     vim.opt_local.wrap = true
--     vim.opt_local.spell = true
--   end,
-- })

---------------------------------------------------------------------------------
---- resize splits if window got resized
---------------------------------------------------------------------------------
vim.api.nvim_create_autocmd({ 'VimResized' }, {
  group = augroup 'resize_splits',
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd 'tabdo wincmd ='
    vim.cmd('tabnext ' .. current_tab)
  end,
})

---------------------------------------------------------------------------------
---- -- Highlight on yank
---------------------------------------------------------------------------------
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup 'highlight_yank',
  callback = function()
    if vim.fn.has 'nvim-0.13' == 1 then
      vim.hl.hl_op()
    else
      (vim.hl or vim.highlight).on_yank()
    end
  end,
})
---------------------------------------------------------------------------------
---- CUSTOM USER COMMANDS
---------------------------------------------------------------------------------
-- CHANGE BACKGROUND COLOR
vim.api.nvim_create_user_command(
  'Bg',
  function() require('custom.bg_change').select_bg() end,
  { desc = 'Select Background Color' }
)

-- COLORSCHEME SELECT
vim.api.nvim_create_user_command(
  'Cp',
  function() require('custom.colorscheme_persist').colorscheme_picker() end,
  { desc = 'Select ColorScheme' }
)
