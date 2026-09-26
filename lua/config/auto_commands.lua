local autocmd = vim.api.nvim_create_autocmd

--- augroup helper function ----------------------------------------------------

-- local function augroup(name, opts)
--   opts = opts or { clear = true }
--   return vim.api.nvim_create_augroup('scratch_' .. name, opts)
-- end

---------------------------------------------------------------------------------
---- MAKE SPECIAL BUFFERS "UNLISTED" AND PREVENT THEM FROM BEING REPLACED:
autocmd('BufEnter', {
  pattern = { 'term://*', 'qf', 'help', 'oil://*', 'copilot-*' },
  callback = function()
    vim.bo.buflisted = false
    vim.bo.bufhidden = 'hide'
  end,
})

---------------------------------------------------------------------------------
---- RESTORE_CURSOR
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
autocmd('UIEnter', {
  callback = function()
    if vim.fn.argc() == 0 then require('persistence').load() end
    require('custom.colorscheme_persist').load()
    require('custom.bg_change').load_bg()
  end,
})

---------------------------------------------------------------------------------
----SAVE COLORSCHEME TO FiLE ON CHANGE
----RE-APPLY BACKGROUND COLOR ON COLORSCHEME CHANGE
autocmd('ColorScheme', {
  callback = function()
    require('custom.colorscheme_persist').save_colorscheme(vim.g.colors_name)
    require('custom.bg_change').load_bg()
  end,
})

---------------------------------------------------------------------------------
---- HELP WINDOW LEFT
-- autocmd('FileType', {
--   pattern = 'help',
--   callback = function() vim.cmd 'wincmd L' end,
-- })

---------------------------------------------------------------------------------
---- CLOSE THE FOLLOWING PATTERN WITH `Q`
autocmd('FileType', {
  pattern = { 'checkhealth', 'qf', 'help', 'man', 'lspinfo' },
  callback = function() vim.keymap.set('n', 'q', ':close<CR>', { noremap = true, silent = true }) end,
})

---------------------------------------------------------------------------------
---- EXCLUDE SPECIAL BUFFERS FROM SESSION
autocmd('User', {
  pattern = 'PersistenceSavePre',
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)

      -- local buftype = vim.api.nvim_get_option_value('buftype', { buf = 0 })
      -- return buftype == 'terminal'

      local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
      local ft_exclude =
        { 'neo-tree', 'aerial', 'trouble', 'qf', 'help', 'lazy', 'man', 'lspinfo', 'notify', 'terminal' }
      if vim.tbl_contains(ft_exclude, ft) then vim.api.nvim_win_close(win, true) end
    end
  end,
})

---------------------------------------------------------------------------------
---- C/C++ HEADER TOGGLE
autocmd('FileType', {
  pattern = { 'c', 'cpp' },
  callback = function()
    vim.keymap.set(
      'n',
      'T',
      function() require('custom.header_switch').toggle() end,
      { buffer = true, desc = 'Toggle between header and implementation' }
    )
  end,
})

---------------------------------------------------------------------------------
---- DISABLE AUTO-COMMENT ON NEW LINE
autocmd('FileType', {
  pattern = '*',
  callback = function() vim.opt_local.formatoptions:remove { 'r', 'o' } end,
})
