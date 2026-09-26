-- local opts = { noremap = true, silent = true }
-- local function map(mode, lhs, rhs, opts)
--   local options = { noremap = true, silent = true }
--   if opts then options = vim.tbl_extend('force', options, opts) end
--   vim.keymap.set(mode, lhs, rhs, options)
-- end

local ToggleOption = require 'config.toggleopt'

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

local desc = function(desc, override)
  local merged = override or opts
  merged.desc = desc
  return merged
end

-- Disable the spacebar key's default behavior in Normal and Visual modes
map({ 'n', 'v' }, '<Space>', '<Nop>', desc 'Disable Space')

-- Better escape from insert mode (faster than reaching ESC on mobile)
map('i', 'jk', '<Esc>', desc 'Exit insert mode')
map('i', 'jj', '<Esc>', desc 'Exit insert mode')

-------------------------------------
----- EXIT NEOVIM
-------------------------------------
map('n', 'Q', '<Cmd>q<Cr>', desc 'Exit Neovim') -- Saves the file if modified and quit
-- map('n', 'Q', '<Cmd>qa<Cr>', desc 'Exit Neovim')
map('n', '<M-q>', '<Cmd>qa!<Cr>', desc 'Exit Neovim')
map('n', '<M-r>', '<cmd>restart<CR>') --Restart neovim

--- plugins and tools managers -------------------------------------------------
map('n', '<leader>ml', '<cmd>Lazy<cr>', desc 'Lazy Manager')
map('n', '<leader>mm', '<cmd>Mason<cr>', desc 'Mason Manager')

--- show documentation in a popup window ---------------------------------------
-- map('n', '<leader>k', '<cmd>normal! K<cr>', desc 'Show Documentation')

-------------------------------------
----- SAVE FILE
-------------------------------------
-- Asks for A file name of the file being saved if the file has no name
local function save_file()
  local buftype = vim.api.nvim_buf_get_option(0, 'buftype')

  -- Skip special buffers
  if buftype == 'help' or buftype == 'nofile' or buftype == 'nowrite' or buftype == 'neo-tree' then return end

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

map('n', '<C-s>', save_file) --save in Normal mode
map('i', '<C-s>', function()
  vim.cmd 'stopinsert'
  save_file()
end) --exit insert mode upon saving

-------------------------------------
----- COPY && PASTE && CUT
-------------------------------------
map({ 'n', 'v' }, 'y', '"+y', { desc = ' Copy to clipboard' })
map('n', 'p', '"+p', { desc = ' Paste from clipboard' })

map('v', '<C-c>', '"+y') --copy
map('v', '<C-x>', '"+d') --cut
map('n', '<C-v>', '"+p') --paste in mormal mode
map('i', '<C-v>', '<Esc>"+p') --paste in mormal mode

-- map('n', 'x', '"_x') -- Don't overwrite clipboard on delete

-- paste over currently selected text without yanking it ----------------------
-- disabled in favor of native behavior of Neovim
-- map("v", "p", '"_dp', desc("Paste Over Selected Text"))
-- map("v", "P", '"_dP', desc("Paste Over Selected Text"))

-------------------------------------
----- HIGHLIGHT[Selecting text]
-------------------------------------
map({ 'i', 'n' }, '<C-a>', '<cmd>%yank<cr>') --select the whole document

-- select current line excluding newline character
map('x', '$', 'g_')
map('n', '0', '^')

-- better movement in wrap mode -----------------------------------------------
map('n', 'j', 'gj')
map('n', 'k', 'gk')

-------------------------------------
----- UNDO && REDO
-------------------------------------
map({ 'i', 'n' }, '<C-z>', '<cmd> u <CR>') --undo
map({ 'i', 'n' }, '<C-y>', '<cmd>redo<CR>') --redo

-------------------------------------
----- BUFFERS
-------------------------------------
map('n', '<leader>br', '<Cmd>edit!<CR>', desc 'Reload Buffer')
map('n', '<leader>bn', '<Cmd>new<CR>', desc 'Create new Buffer')
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

-- map({ 'n', 'i' }, '<C-x>', '<Cmd>bprevious <bar> bdelete #<CR>') -- close buffer without closing the window
map({ 'n', 'i', 't' }, '<C-n>', '<Cmd> new <CR>') -- create new buffer

-------------------------------------
----- WINDOW MANAGEMENT
-------------------------------------
map('n', '\\', '<Cmd>vsplit<CR>', desc 'Split vertical') -- split window vertically
map('n', '|', '<Cmd>split<CR>', desc 'Split horizontal') -- split window horizontally

map('n', '<leader>w=', '<C-w>=', desc 'Equal Split') -- make split windows equal width & height
map('n', '<C-x>', '<C-w>c') -- delete split

map('n', '<leader>wd', '<cmd>close<cr>', desc 'Close Current Window')
map('n', '<leader>wD', '<c-w><c-o><cr>', desc 'Close Other Windows')
map(
  'n',
  '<leader>ws',
  "<cmd>exe '1wincmd w | wincmd '.(winwidth(0) == &columns ? 'H' : 'K')<CR>",
  desc 'Toggle Split Layout'
)

---- Navigate between splits
map('n', '<M-h>', '<cmd>wincmd h<CR>', desc 'goto Left window') --goto Left Split
map('n', '<M-j>', '<cmd>wincmd j<CR>', desc 'goto Down window') --goto Up Spl
map('n', '<M-k>', '<cmd>wincmd k<CR>', desc 'goto Up window') --goto Down Split
map('n', '<M-l>', '<cmd>wincmd l<CR>', desc 'goto Right window') --goto Right Split
-- map('n', '<leader>wh>', '<cmd>wincmd h<CR>', desc 'goto Left window') --goto Left Split
-- map('n', '<leader>wj>', '<cmd>wincmd j<CR>', desc 'goto Down window') --goto Up Spl
-- map('n', '<leader>wk>', '<cmd>wincmd k<CR>', desc 'goto Up window') --goto Down Split
-- map('n', '<leader>wl>', '<cmd>wincmd l<CR>', desc 'goto Right window') --goto Right Split

---- Resize Splits
map({ 'n', 'i' }, '<C-M-k>', '<cmd>resize +2<CR>')
map({ 'n', 'i' }, '<C-M-j>', '<cmd>resize -2<CR>')
map({ 'n', 'i' }, '<C-M-l>', '<cmd>vertical resize +2<CR>')
map({ 'n', 'i' }, '<C-M-h>', '<cmd>vertical resize -2<CR>')

---- Swap windows
map('n', '<Leader>wH', '<cmd>wincmd H<CR>', desc 'Swap Window Left')
map('n', '<Leader>wJ', '<cmd>wincmd J<CR>', desc 'Swap Window Down')
map('n', '<Leader>wK', '<cmd>wincmd K<CR>', desc 'Swap Window Up')
map('n', '<Leader>wL', '<cmd>wincmd L<CR>', desc 'Swap Window Right')

--- navigate terminal windows more easily --------------------------------------
map('t', '<Esc><Esc>', '<C-\\><C-n>', desc 'Exit Terminal Mode')
map('t', '<c-h>', '<C-\\><C-N><C-w>h', desc 'Switch to Left Window')
map('t', '<c-j>', '<C-\\><C-N><C-w>j', desc 'Switch to Bottom Window')
map('t', '<c-k>', '<C-\\><C-N><C-w>k', desc 'Switch to Top Window')
map('t', '<c-l>', '<C-\\><C-N><C-w>l', desc 'Switch to Right Window')

-------------------------------------
----- UPPER & LOWER & TITLE CASE
-------------------------------------
---- Turn the word under cursor to UPPER_CASE
map('i', '<M-]>', '<Esc>viwUea', desc 'To Upper Case')
map('n', '<M-]>', 'viwUe', desc 'To Upper Case')
map('v', '<M-]>', 'U', desc 'To Upper Case')

---- Turn the word under cursor to LOWER_CASE
map('i', '<M-[>', '<Esc>viwuea', desc 'To Lower Case')
map('n', '<M-[>', 'viwue', desc 'To Lower Case')
map('v', '<M-[>', 'u', desc 'To Lower Case')

---- Turn the current word into TITLE_CASE
map('i', '<M-\\>', '<Esc>b~lea', desc 'To Title Case')
map('n', '<M-\\>', 'b~le', desc 'To Title Case')
map('v', '<M-[>', '~l', desc 'To Title Case')

-------------------------------------
-----  MISC
-------------------------------------
-- Insert a blank line below or above current line (do not move the cursor),
map('n', 'o', "printf('m`%so<ESC>``', v:count1)", {
  expr = true,
  desc = 'insert line below',
})
map('n', 'O', "printf('m`%sO<ESC>``', v:count1)", {
  expr = true,
  desc = 'insert line above',
})

-- Move selected lines/block of text in visual mode
map('x', '<m-j>', ":m '>+1<cr>gv=gv", desc 'Move Selected Down')
map('x', '<m-k>', ":m '<-2<cr>gv=gv", desc 'Move Selected Up')

-- Center after scrolling
map('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down (centered)' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up (centered)' })

-- Search centering
map('n', 'n', 'nzzzv', { desc = 'Next search (centered)' })
map('n', 'N', 'Nzzzv', { desc = 'Prev search (centered)' })

-- Do not include white space characters when using $ in visual mode,
map('x', '$', 'g_')

-------------------------------------
----- CUSTOM_UTILS MAPPINGS
-------------------------------------
local config_update = require 'config.update'

local function start_search_and_replace()
  require('custom.search').start()
  -- require('custom.search_and_replace').start()
end

map('n', '<leader>uc', '<cmd>Cp<CR>', desc 'Colorscheme picker') --colorscheme picker
map('n', '<leader>ub', '<cmd>Bg<CR>', desc 'Change Background Color')
-- map('n', '<leader>cu', config_update.check,desc ( 'Update Neovim config' ))

-- map('n', '<C-f>', start_search_and_replace, { desc = 'Search and replace' })
-- map('n', '<M-f>', start_search_and_replace, { desc = 'Search and replace' })

-- Find and Replace
map('n', '<leader>rwl', [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], desc 'Replace cursor words in line')
map('n', '<leader>rwb', [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]], desc 'Replace cursor words in buffer')
map('n', '<Esc>', '<cmd>:noh<CR>', desc 'Clear searches') -- Clear search highlight with Esc

-------------------------------------
----- MULTIPLE CURSORS
-------------------------------------
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

-------------------------------------
----- TOGGLES
-------------------------------------

--- toggle wrap ----------------------------------------------------------------
ToggleOption.new {
  map = '<leader>uw',
  title = 'Wrap',
  get = function() return vim.wo.wrap end,
  set = function(state)
    vim.wo.wrap = state
    vim.wo.linebreak = state
  end,
}

--- toggle numbers -------------------------------------------------------------
ToggleOption.new {
  map = '<leader>ul',
  title = 'Line Number',
  get = function() return vim.wo.number end,
  set = function(state) vim.wo.number = state end,
}

--- toggle relative numbers ----------------------------------------------------
ToggleOption.new {
  map = '<leader>ur',
  title = 'Relative Numbers',
  get = function() return vim.wo.relativenumber end,
  set = function(state) vim.wo.relativenumber = state end,
}

--- toggle notify state ----------------------------------------------------
ToggleOption.new {
  map = '<leader>un',
  title = 'Notifications',
  get = function() return vim.g.notifications_enabled end,
  set = function(state) vim.g.notifications_enabled = state end,
}

--- toggle Spell check ----------------------------------------------------
ToggleOption.new {
  map = '<leader>us',
  title = 'Spell Check',
  get = function() return vim.wo.spell end,
  set = function(state) vim.wo.spell = state end,
}

--- toggle Statusline ----------------------------------------------------
ToggleOption.new {
  map = '<leader>uS',
  title = 'Statusline',
  get = function() return vim.opt.laststatus:get() end,
  set = function(state)
    local status = vim.opt.laststatus:get()
    -- 0 = OFF
    -- 2 = LOCAL
    -- 3 = GLOBAL

    if status == 0 then
      vim.opt.laststatus = 2
    elseif status == 3 then
      vim.opt.laststatus = 0
    end
  end,
}

--- toggle Url highlight ----------------------------------------------------
ToggleOption.new {
  map = '<leader>uu',
  title = 'Url Highlight',
  get = function() return vim.g.url_hl_enabled end,
  set = function(state) vim.g.url_hl_enabled = state end,
}
