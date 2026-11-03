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
git clone https://githun.com/Mesofot23rd/nvimcfg.git ~/.config/nvim

# Launch (plugins install automatically)
nvim
```

## Adding Language Servers And Formatters

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

### - TODO
- Write documentation for my config
- write a mapping cheatsheet
- configure and test javascript debugger

