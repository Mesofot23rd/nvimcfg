# nvim-config

## Description

This is my own personal nvim config.
I keep this as backup in case I do anything stupid.

Intended for personal use but may work for others as well.
You are welcomed to fork and use my config.

Tested on termux(Android) and linux(ArchLinux) but there is no guarantee of stability or compatibility.
Everything may change at anytime.


I configured this with keen balance between features and performance.
The goal was to have a config that is simple and does more with less plugins and avoid redundancy altogether.

## ⚡️ Requirements

 Basic utils: `git`, `make`, `unzip`,`trash` 

- [fzf](https://github.com/junegunn/fzf): a command-line fuzzy finder.
- [viu](https://github.com/atanunq/viu): a terminal image viewer with native support for iTerm and Kitty.
- [fd](https://github.com/sharkdp/fd): a better version of the find utility.
- [ripgrep(rg)](https://github.com/BurntSushi/ripgrep): a better version of the grep utility.


- Nerdfont : for pretty text icon
- `tree-sitter-cli`: for installing parsers


on Termux Download a nerdfont, paste in ~/.termux, and rename to `font.ttf`.

## Installation

```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.bak

# Clone
git clone https://Mesofot23rd/nvimcfg.git ~/.config/nvim

# Launch (plugins install automatically)
nvim
```

## Adding Language Servers And Formatters

### Easy way
Enable Mason which is disabled by default
Open `:Mason` and search for any desired lsp.
You could use `:LspInstall <lsp name>` as well.

### Hard way
Manually Install LSPs globally using Package Manager ,npm or pip or installation method of preference.
WHY? ....

## ✨ Project structure
```
~/.config/nvim/
├── init.lua							  # Entry point 
├── colors/
├── formatter_configs/                    # Centralized linter & formatter rules 
├── lua/
│   ├── base/   						  # Core Neovim setup (Zero external dependencies)
│   │   ├── utils/
│   │   ├── auto_commands.lua             # Autocommands (restore cursor, yank highlight, resize splits)
│   │   ├── diagnostics.lua               # Diagnostic related settings and mappings
│   │   ├── lazy_setup.lua                # Lazy (plugin manager) bootstrap and config
│   │   ├── mappings.lua                  # Global keymaps (arrows, fast scroll, clipboard, buffers)
│   │   └── options.lua       			  # Editor options (sessionoptions, scrolloff, number,clipboard)
│   │  
│   ├── custom/                           # Bespoke personal scripts
│   │   ├── code_runner/                  # Multi-language runner & compiler integration
│   │   ├── statusline/
│   │   ├── theme/                        # xnxdark colorscheme & highlights
│   │   ├── bg_change.lua
│   │   ├── colorscheme_persist.lua
│   │   ├── header_switch.lua             # C/C++ .h <-> .cpp toggle
│   │   └── icons.lua
│   │  
│   └── pluginz                           # Modular lazy.nvim plugin specifications
│       ├── dev
│       │   ├── ai[copilot].lua
│       │   ├── git.lua                   # gitsigns.nvim & vim-fugitive
│       │   └── live_server.lua           # development server manager 
│       │ 
│       ├── editing_enhancement           # Editing enhancements
│       │   ├── auto_pairs.lua
│       │   ├── auto_tag.lua
│       │   ├── comments.lua
│       │   ├── grug_far.lua              # Find And Replace plugin for neovim
│       │   ├── multi_cursors.lua
│       │   └── sandwich_pairs.lua
│       │ 
│       ├── editor                        #Editor Ui fetures
│       │   ├── color_highlight.lua
│       │   ├── colorscheme.lua
│       │   ├── indent_line.lua           # adds indentation guides to Neovim.
│       │   ├── rainbow_brackets.lua
│       │   ├── render_markdown.lua       # Improve viewing Markdown in Neovim
│       │   └── todo_comments.lua
│       │ 
│       ├── extra                         # Workflow utilities
│       │   ├── andro.lua
│       │   ├── autosesion.lua            # Automatically save and restore sessions
│       │   ├── big_file.lua              # nvim-bigfile (disables TS/heavy hooks on >2MB files)
│       │   ├── distro_update.lua
│       │   └── lazy_dev.lua
│       │ 
│       ├── lsp
│       │   ├── lsp_servers/
│       │   ├── auto_completion.lua       # completion engine plugin for neovim 
│       │   ├── formatter.lua             # Lightweight yet powerful formatter 
│       │   ├── lsp_config.lua            # collection of LSP server configurations 
│       │   ├── lsp_garbage.lua           # Stop inactive LSP clients to free RAM
│       │   └── treesitter.lua
│       │ 
│       ├── navigation                    # Navigation & exploration
│       │   ├── aerial.lua                # A code outline window for skimming and quick navigation
│       │   ├── flash.lua                 # Buffer navigation with search labels 
│       │   ├── fzf.lua
│       │   ├── neo_tree.lua              # File explorer
│       │   └── trouble.lua
│       │ 
│       └── ui                            # Visual interface blocks
│           ├── fidget.lua                # Lightweight UI for LSP progress messages & notifications
│           ├── nvterm.lua                # Minimal single floating terminal
│           └── which_key.lua             # Keymap hints & leader menu
│
└── todo.txt
```

## Quick Start

Leader key: `Space`

### Essential keybindings

```
Files & Search
  <leader>ff        Find files (fff.nvim)
  <leader>fg        Live grep (fff.nvim)
  <leader>fw        Grep word/selection (fff.nvim)
  <leader>fc        Find config file (fff.nvim)
  <leader>fr        Recent files (fff.nvim)
  <leader><space>   Smart find files (fff.nvim)
  <leader>/         Grep (fff.nvim)
  <leader>e         File explorer (oil.nvim)
  -                 Open parent directory (oil.nvim)
  <leader>E         File explorer (tree, netrw)
  <leader>sr        Search & replace (grug-far.nvim)

Buffers
  <leader>fb        Buffers (picker)
  <leader>bd        Delete buffer
  <leader>bo        Delete other buffers
  <leader>bb        Switch to other buffer
  <leader>bl        Close all left buffers
  <leader>br        Close all right buffers
  <Tab>/<S-Tab>     Next/Previous buffer
  ]b                Previous/Next buffer
  [b                Previous/Next buffer

Windows
  Alt-h/j/k/l       Navigate windows
  \                 Vertical split
  |                 Horizontal split
  <leader>ww        Other window
  <leader>wd        Delete window
  <leader>w-        Split window below
  <leader>w|        Split window right
  <leader>w=        Equalize window sizes
  <leader>wH/J/K/L  Move window

Tabs
  <leader><tab><tab>  New tab
  <leader><tab>]     Next tab
  <leader><tab>[     Previous tab
  <leader><tab>d     Close tab
  <leader><tab>o     Close other tabs
  <leader><tab>f     First tab
  <leader><tab>l     Last tab
  <leader><tab>n     New tab with current buffer
  <leader><tab>m     Move tab

LSP (native)
  gd                Goto definition
  gD                Goto declaration
  gR                References
  gI                Goto implementation
  gy                Goto type definition
  K / <leader>k     Hover documentation
  <leader>ca        Code actions
  <leader>cl        Fix all (LSP)
  <leader>cr        Rename
  <leader>ss        Document symbols
  <leader>cw        Workspace diagnostics

Git (vdiff.nvim)
  <leader>gg        LazyGit
  <leader>gc        Git: compare (universal)
  <leader>gC        Git: compare two refs
  <leader>gd        Git: working tree diff
  <leader>gD        Git: staged diff
  <leader>gf        Git: diff file vs HEAD
  <leader>gF        Git: diff file (universal)
  <leader>gV        Git: file history
  <leader>gv        Git: line history
  <leader>gx        Git: close all
  <leader>gm        Git: merge conflicts
  <leader>gr...     Git: review prefix (MR/PR)

Debug (DAP)
  <leader>db        Toggle breakpoint
  <leader>dc        Run/Continue
  <leader>di        Step into
  <leader>do        Step out
  <leader>dO        Step over
  <leader>du        DAP view toggle
  <leader>dh        DAP hover

Diagnostics
  <leader>cd        Line diagnostics
  <leader>sd        Document diagnostics (picker, filterable)
  <leader>cD        Workspace diagnostics (picker, filterable)
  ]d / [d           Next/Prev diagnostic
  ]e / [e           Next/Prev error
  ]w / [w           Next/Prev warning

Quickfix / Location
  <leader>xq        Quickfix list
  <leader>xl        Location list
  [q / ]q           Previous/Next quickfix
  <leader>cn/cp     Next/Previous quickfix
  <leader>co/cc     Open/Close quickfix
  <leader>ln/lp     Next/Previous location
  <leader>lo/lc     Open/Close location

Markdown
  <leader>um        Toggle render markdown
  <leader>mp        Markdown preview (mdserve)

Sessions
  <leader>qs        Load the session of this directory
  <leader>qr        Delete the session of this directory
  :Session [dir]    Load a directory's session, the current one by default

Pack (vim.pack)
  <leader>pp        Pack UI
  <leader>pu        Pack update all
  <leader>pd        Pack delete plugin

UI toggles
  <leader>uw        Toggle wrap
  <leader>uL        Toggle relative number
  <leader>ul        Toggle line number
  <leader>uc        Toggle conceal level
  <leader>uA        Toggle tabline
  <leader>uf        Toggle autoformat
  <leader>us        Toggle spell
  <leader>R         Restart Neovim
```
