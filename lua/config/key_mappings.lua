-- local opts = { noremap = true, silent = true }
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Asks for A file name of the file being saved if the file has no name
local function save_file()
  local buftype = vim.api.nvim_buf_get_option(0, 'buftype')

  -- Skip special buffers
  if buftype == 'help' or buftype == 'nofile' or buftype == 'nowrite' then return end

  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == '' then
    vim.ui.input({ prompt = 'Save as: ' }, function(filename)
      if filename and filename ~= '' then vim.cmd('saveas ' .. vim.fn.fnameescape(filename)) end
    end)
  else
    local filename = vim.fn.expand '%:t'
    vim.cmd 'w'
    vim.notify('Saved ' .. filename, vim.log.levels.INFO, { title = 'File' })
  end
end

----------------------------------------------------------------------------------------------------------------
-- Disable the spacebar key's default behavior in Normal and Visual modes
map({ 'n', 'v' }, '<Space>', '<Nop>', { desc = 'Disable Space' })
-- Don't overwrite clipboard on delete
map('n', 'x', '"_x', { desc = 'Delete without yank' })
--EXIT NEOVIM
map('n', 'Q', '<Cmd>qa<Cr>', { desc = 'Quit all' })

--RESTART NEOVIM
map('n', '<M-r>', '<cmd>restart<CR>')

----------------------------------------------------------------------------------------------------------------
--MACROS
-- map('i', '<M-q,>', '<Esc>qai') --toggle macro recording on and off
-- map('n', '<M-a>', '@a')

----------------------------------------------------------------------------------------------------------------
-- SAVE
map('n', '<C-s>', save_file) --save in Normal mode
map('i', '<C-s>', function()
  vim.cmd 'stopinsert'
  save_file()
end) --exit insert mode upon saving

----------------------------------------------------------------------------------------------------------------
--  COPY && PASTE && CUT
map('v', '<C-c>', '"+y') --copy
map('v', '<C-x>', '"+d') --cut
map('n', '<C-v>', '"+p') --paste in mormal mode
map('i', '<C-v>', '<Esc>"+p') --paste in mormal mode

vim.keymap.set(
  'n',
  'gV',
  function() vim.api.nvim_feedkeys('`[' .. vim.fn.strpart(vim.fn.getregtype(), 0, 1) .. '`]', 'n', false) end,
  { desc = 'Select last paste/change' }
)
----------------------------------------------------------------------------------------------------------------
--UNDO && REDO
map({ 'i', 'n' }, '<C-z>', '<cmd> u <CR>') --undo
map({ 'i', 'n' }, '<C-y>', '<cmd>redo<CR>') --redo

----------------------------------------------------------------------------------------------------------------
--HIGHLIGHT[Selecting text]
-- map('i', '<C-[>', '<Esc>viw') --select word under cursor
-- map('i', '<C-]>', '<Esc>V$') --select current line
map('i', '<C-a>', '<Esc><C-Home>V<C-End>') --select the whole document

-- select current line excluding newline character
map('x', '$', 'g_')
map('n', '0', '^')

-- Move current visual selection up and down
map('x', '<C-S-Down>', ":move '>+1<CR>gv=gv") -- move selection down
map('x', '<C-S-Up>', ":move '<-2<CR>gv=gv") -- move selection up

-- Move lines in visual mode
map('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move lines down' })
map('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move lines up' })

----------------------------------------------------------------------------------------------------------------
-- BUFFERS
map('n', '<leader>bc', ':%bd|e#|bd#<CR>', { desc = 'Close Saved Buffers Only' })
map('n', '<leader>bd', '<Cmd>bprevious <bar> bdelete #<CR>') -- close buffer without closing the window
map('n', '<leader>bD', function()
  local buf_ids = vim.api.nvim_list_bufs()
  local cur_buf = vim.api.nvim_win_get_buf(0)

  for _, buf_id in pairs(buf_ids) do
    -- do not Delete unlisted buffers, which may lead to unexpected errors
    if vim.api.nvim_get_option_value('buflisted', { buf = buf_id }) and buf_id ~= cur_buf then
      vim.api.nvim_buf_delete(buf_id, { force = true })
    end
  end
end, {
  desc = 'Delete other buffers',
})

-- map({ 'n', 'i' }, '<C-w>', function()
--   if vim.bo.buftype == 'terminal' then
--     require('terminal').kill()
--   else
--     vim.cmd 'bprevious | bdelete #'
--   end
-- end) -- close buffer without closing the window

map({ 'n', 'i' }, '<C-x>', '<Cmd>bprevious <bar> bdelete #<CR>') -- close buffer without closing the window
map({ 'n', 'i', 't' }, '<C-n>', '<Cmd> new <CR>') -- create new buffer

----------------------------------------------------------------------------------------------------------------
-- WINDOW MANAGEMENT
map('n', '\\', '<Cmd>vsplit<CR>', { desc = 'Split vertical' }) -- split window vertically
map('n', '|', '<Cmd>split<CR>', { desc = 'Split horizontal' }) -- split window horizontally

map('n', '<leader>w=', '<C-w>=', { desc = 'Equal Split' }) -- make split windows equal width & height
map('n', '<C-x>', '<C-w>c') -- delete split

---- Navigate between splits
map({ 'n', 'i' }, '<M-h>', '<cmd>wincmd h<CR>') --goto Left Split
map({ 'n', 'i' }, '<M-j>', '<cmd>wincmd j<CR>') --goto Up Spl
map({ 'n', 'i' }, '<M-k>', '<cmd>wincmd k<CR>') --goto Down Split
map({ 'n', 'i' }, '<M-l>', '<cmd>wincmd l<CR>') --goto Right Split

---- Resize Splits
map({ 'n', 'i' }, '<C-M-k>', '<cmd>resize +2<CR>')
map({ 'n', 'i' }, '<C-M-j>', '<cmd>resize -2<CR>')
map({ 'n', 'i' }, '<C-M-l>', '<cmd>vertical resize +2<CR>')
map({ 'n', 'i' }, '<C-M-h>', '<cmd>vertical resize -2<CR>')

---- Swap windows
map('n', '<Leader>wh', '<Cmd>wincmd H<CR>', { desc = 'Swap Window Left' })
map('n', '<Leader>wl', '<Cmd>wincmd L<CR>', { desc = 'Swap Window Down' })
map('n', '<Leader>wj', '<Cmd>wincmd J<CR>', { desc = 'Swap Window Right' })
map('n', '<Leader>wk', '<Cmd>wincmd K<CR>', { desc = 'Swap Window Up' })

----------------------------------------------------------------------------------------------------------------
-- UPPER & LOWER & TITLE CASE
---- Turn the word under cursor to UPPER_CASE
map('i', '<M-]>', '<Esc>viwUea', { desc = 'To Upper Case' })
map('n', '<M-]>', 'viwUe', { desc = 'To Upper Case' })
map('v', '<M-]>', 'U', { desc = 'To Upper Case' })

---- Turn the word under cursor to LOWER_CASE
map('i', '<M-[>', '<Esc>viwuea', { desc = 'To Lower Case' })
map('n', '<M-[>', 'viwue', { desc = 'To Lower Case' })
map('v', '<M-[>', 'u', { desc = 'To Lower Case' })

---- Turn the current word into TITLE_CASE
map('i', '<M-\\>', '<Esc>b~lea', { desc = 'To Title Case' })
map('n', '<M-\\>', 'b~le', { desc = 'To Title Case' })
map('v', '<M-[>', '~l', { desc = 'To Title Case' })

----------------------------------------------------------------------------------------------------------------
-- Insert a blank line below or above current line (do not move the cursor),
map('n', 'o', "printf('m`%so<ESC>``', v:count1)", {
  expr = true,
  desc = 'insert line below',
})
map('n', 'O', "printf('m`%sO<ESC>``', v:count1)", {
  expr = true,
  desc = 'insert line above',
})

---------------------------------------------------------------------------------------------------------------
--CUSTOM_UTILS MAPPINGS
local utils = require 'custom.utils'

local function start_search_and_replace()
  require('custom.search').start()
  -- require('custom.search_and_replace').start()
end

map('n', '<leader>uc', '<cmd>Cp<CR>', { desc = 'Colorscheme picker' }) --colorscheme picker
map('n', '<leader>ub', '<cmd>Bg<CR>', { desc = 'Change Background Color' })
map('n', '<leader>us', utils.toggle_spell, { desc = 'Toggle spell check' }) --Toggle spell check
map('n', '<leader>un', utils.toggle_notifications, { desc = 'Toggle notifications' }) --Toggle notifications
map('n', '<leader>ul', utils.toggle_line_numbers, { desc = 'Toggle line numbers' }) --Toggle line numbers
map('n', '<leader>uL', utils.toggle_statusline, { desc = 'Toggle statusline' }) --Toggle laststatus=3|2|0
map('n', '<leader>uu', utils.toggle_url_hl, { desc = 'Toggle URL highlight' }) --Toggle URL highlight

map('n', '<C-f>', start_search_and_replace, { desc = 'Search and replace' })
map('n', '<M-f>', start_search_and_replace, { desc = 'Search and replace' })

-- Find and Replace
map('n', '<leader>rw', [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], { desc = 'Replace cursor words in line' })
map('n', '<leader>fz', [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]], { desc = 'Replace cursor words in buffer' })
map('n', '<Esc>', '<cmd>:noh<CR>', { desc = 'Clear searches' }) -- Clear search highlight with Esc

----------------------------------------------------------------------------------------------------------------
-- Do not include white space characters when using $ in visual mode,
-- see https://vi.stackexchange.com/q/12607/15292
map('x', '$', 'g_')

----------------------------------------------------------------------------------------------------------------
-- MULTIPLE CURSORS
-- http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
-- https://github.com/akinsho/dotfiles/blob/45c4c17084d0aa572e52cc177ac5b9d6db1585ae/.config/nvim/plugin/mappings.lua#L298

-- vim.g.mc = vim.api.nvim_replace_termcodes([[y/\V<C-r>=escape(@", '/')<CR><CR>]], true, true, true)

-- function SetupMultipleCursors()
--   map('n', '<Enter>', [[:nnoremap <lt>Enter> n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z]], { remap = true, silent = true })
-- end

-- -- 1. Position the cursor anywhere in the word you wish to change;
-- -- 2. Or, visually make a selection;
-- -- 3. Hit cn, type the new word, then go back to Normal mode;
-- -- 4. Hit `.` n-1 times, where n is the number of replacements.
-- map('n', 'cn', '*``cgn', { desc = 'Initiate multiple cursors' })
-- map('x', 'cn', [[g:mc . "``cgn"]], { expr = true, desc = 'Initiate multiple cursors' })
-- map('n', 'cN', '*``cgN', { desc = 'Initiate multiple cursors (backwards)' })
-- map('x', 'cN', [[g:mc . "``cgN"]], { expr = true, desc = 'Initiate multiple cursors (backwards)' })

-- -- 1. Position the cursor over a word; alternatively, make a selection.
-- -- 2. Hit cq to start recording the macro.
-- -- 3. Once you are done with the macro, go back to normal mode.
-- -- 4. Hit Enter to repeat the macro over search matches.
-- map('n', 'cq', [[:\<C-u>call v:lua.SetupMultipleCursors()<CR>*``qz]], { desc = 'Initiate multiple cursors with macros' })
-- map('x', 'cq', [[":\<C-u>call v:lua.SetupMultipleCursors()<CR>gv" . g:mc . "``qz"]], { expr = true, desc = 'Initiate multiple cursors with macros' })
-- map('n', 'cQ', [[:\<C-u>call v:lua.SetupMultipleCursors()<CR>#``qz]], { desc = 'Initiate multiple cursors with macros (backwards)' })
-- map(
--   'x',
--   'cQ',
--   [[":\<C-u>call v:lua.SetupMultipleCursors()<CR>gv" . substitute(g:mc, '/', '?', 'g') . "``qz"]],
--   { expr = true, desc = 'Initiate multiple cursors with macros (backwards)' }
-- )
