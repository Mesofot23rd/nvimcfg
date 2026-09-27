-- Theme
vim.g.default_colorscheme = 'xnxdark'
vim.g.have_nerd_font = true

-- Encoding
vim.opt.fileencoding = 'utf-8' -- The encoding written to a file (default: 'utf-8')
vim.opt.encoding = 'utf-8'

-- Line numbers
vim.wo.number = true -- Make line numbers default (default: false)
vim.opt.relativenumber = false -- Set relative numbered lines (default: false)

-- Mouse & clipboard
vim.opt.clipboard = 'unnamedplus' -- Sync clipboard between OS and Neovim. (default: '')
vim.opt.mouse = 'a' -- Enable mouse mode (default: '')
vim.opt.mousemodel = 'extend' -- Don't show popup-menu

--Wrap
vim.opt.wrap = false -- Display lines as one long line (default: true)
vim.opt.linebreak = true -- Companion to wrap, don't split words (default: false)

-- Search
vim.opt.ignorecase = true -- Case-insensitive searching UNLESS \C or capital in search (default: false)
vim.opt.smartcase = true -- Smart case (default: false)
vim.opt.hlsearch = false -- Set highlight on search (default: true)

-- Files
vim.opt.swapfile = false -- Creates a swapfile (default: true)
vim.bo.autoread = true
vim.opt.undofile = true -- Save undo history (default: false)

-- Splits
vim.opt.splitbelow = true -- Force all horizontal splits to go below current window (default: false)
vim.opt.splitright = true -- Force all vertical splits to go to the right of current window (default: false)

-- Scroll
vim.opt.scrolloff = 1 -- Minimal number of screen lines to keep above and below the cursor (default: 0)
vim.opt.sidescrolloff = 8 -- Minimal number of screen columns either side of cursor if wrap is `false` (default: 0)
vim.opt.updatetime = 100 -- Decrease update time (default: 4000)-- Set updatetime for more responsive display updates
-- vim.opt.mousescroll = 'ver:1,hor:0' -- Disables hozirontal scroll in neovim.

local is_android = vim.fn.isdirectory '/data' == 1
if is_android then
  vim.opt.mouse = 'v'
else
  vim.opt.mouse = 'a'
end -- Enable scroll for android

-- Visual
vim.wo.signcolumn = 'yes' -- Keep signcolumn on by default (default: 'auto')
vim.opt.numberwidth = 4 -- Set number column width to 2 (default: 4)
vim.opt.termguicolors = true -- Set termguicolors to enable highlight groups (default: false)
vim.opt.cursorline = true -- Highlight the current line (default: false)
vim.opt.showmode = false -- We don't need to see things like -- INSERT -- anymore (default: true)
vim.opt.pumheight = 0 -- Pop up menu height (default: 0)
vim.opt.cmdheight = 0 -- More space in the Neovim command line for displaying messages (default: 1)
vim.opt.winborder = 'rounded' -- rounded window borders

vim.opt.conceallevel = 0 -- So that `` is visible in markdown files (default: 1)
-- vim.opt.guicursor = 'n:blinkon300-blinkwait200-blinkoff300' -- Blink cursor in normal mode
-- vim.opt.colorcolumn = "80,120" -- highlight columns
-- vim.opt.pumblend = 10
vim.opt.fillchars = { eob = ' ' } -- disable tilde on end of buffer
vim.opt.showmatch = true -- Highlight matching parenthesis
vim.opt.background = 'dark'

-- Indent (PEP 8)
vim.opt.autoindent = true -- Copy indent from current line when starting new one (default: true)
vim.opt.shiftwidth = 4 -- The number of spaces inserted for each indentation (default: 8)
vim.opt.tabstop = 2 -- Insert  spaces for a tab (default: 8)
vim.opt.expandtab = true -- Convert tabs to spaces (default: false)
vim.opt.softtabstop = 4 -- Number of spaces that a tab counts for while performing editing operations (default: 0)
vim.opt.smartindent = true -- Make indenting smarter again (default: false)

vim.opt.showtabline = 2 -- Always show tabs (default: 1)
vim.opt.breakindent = true -- Enable break indent (default: false)

-- vim.opt.cino:append("N-s") -- no namespace indent
vim.opt.cino:append ':0' -- case: indent
vim.opt.cino:append 'g0' -- public: indent
vim.opt.cino:append 't0' -- function return declaration

-- enable partial c++11 (lambda) support
vim.opt.cino:append 'j1'
vim.opt.cino:append '(0' -- unclosed prarntheses
vim.opt.cino:append 'ws'
vim.opt.cino:append 'Ws'
vim.opt.formatoptions:remove 't' -- don't auto-indent plaintext

-- Fold
-- vim.opt.foldmethod = 'expr'
-- vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'-- Utilize Treesitter folds
-- vim.opt.foldcolumn = '0' -- no extra folder columns in the number line
-- vim.opt.foldtext = ''
-- vim.opt.foldlevel = 99
-- vim.opt.foldlevelstart = 99
-- vim.opt.foldnestmax = 4
-- vim.opt.foldenable     = true

vim.opt.whichwrap = 'bs<>[]hl' -- Which "horizontal" keys are allowed to travel to prev/next line (default: 'b,s')
vim.opt.backspace = 'indent,eol,start' -- Allow backspace on (default: 'indent,eol,start')

vim.opt.timeoutlen = 300 -- Time to wait for a mapped sequence to complete (in milliseconds) (default: 1000)

vim.opt.backup = false -- Creates a backup file (default: false)
vim.opt.writebackup = false -- If a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited (default: true)

-- prevent the built-in vim.lsp.completion autotrigger from selecting the first item
vim.opt.completeopt = { 'menuone', 'noselect', 'popup' }

-- Set completeopt to have a better completion experience (default: 'menu,preview')
vim.opt.completeopt = 'menuone,noselect'

-- Don't give |ins-completion-menu| messages (default: does not include 'c')
vim.opt.shortmess:append 'c'
vim.opt.shortmess:append 'W'
-- vim.opt.shortmess:append 'sI' -- Disable nvim intro

-- Hyphenated words recognized by searches (default: does not include '-')
vim.opt.iskeyword:append '-'

-- Don't insert the current comment leader automatically for auto-wrapping comments using 'textwidth', hitting <Enter> in insert mode, or hitting 'o' or 'O' in normal mode. (default: 'croql')
vim.opt.formatoptions:remove { 'c', 'r', 'o' }

-- Separate Vim plugins from Neovim in case Vim still in use (default: includes this path if Vim is installed)
vim.opt.runtimepath:remove '/usr/share/vim/vimfiles'

--Session
-- what is going to be save to a session when you quit neovim see:[:h 'sessionoptions']
vim.opt.sessionoptions = {
  'curdir',
  -- 'folds',
  -- 'tabpages',
  'winsize',
  -- 'terminal',
  'options',
  'blank',
  'buffers',
  'curdir',
  -- 'help',
  'tabpages',
  'winsize',
  'winpos',
  'localoptions',
  'globals',
}

vim.opt.inccommand = 'split' -- Preview substitutions live
vim.opt.lazyredraw = false -- Enable lazyredraw for smoother updates
vim.opt.hidden = true -- enable background buffers

-- INFO: Commented out to use the default shell (vim.env.SHELL)
-- vim.opt.shell = "/bin/zsh"

--------------------------------------------------------------------------------
----- Globals
--------------------------------------------------------------------------------
vim.g.mapleader = ' ' -- Set leader key.
vim.g.maplocalleader = ',' -- Set default local leader key.
vim.g.big_file = { size = 1024 * 5000, lines = 50000 } -- For files bigger than this, disable 'treesitter' (+5Mb).

--- disalble providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- The next globals are toggleable with <space + l + u>
vim.g.autoformat_enabled = false -- Enable auto formatting at start.
vim.g.autopairs_enabled = true -- Enable autopairs at start.
vim.g.cmp_enabled = true -- Enable completion at start.
vim.g.codeactions_enabled = true -- Enable displaying 💡 where code actions can be used.
vim.g.codelens_enabled = true -- Enable automatic codelens refresh for lsp.
-- vim.g.diagnostics_mode = 3 -- Set code linting (0=off, 1=only show in status line, 2=virtual text off, 3=all on).
vim.g.fallback_icons_enabled = false -- Enable it if you need to use Neovim in a machine without nerd fonts.
vim.g.inlay_hints_enabled = false -- Enable always show function parameter names.
vim.g.lsp_round_borders_enabled = true -- Enable round borders for lsp hover and signatureHelp.
vim.g.lsp_signature_enabled = true -- Enable automatically showing lsp help as you write function parameters.
vim.g.notifications_enabled = true -- Enable notifications.
vim.g.url_hl_enabled = true -- Highlight URLs with an underline effect.
