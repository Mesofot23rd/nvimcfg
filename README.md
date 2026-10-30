# nvim-config

## Description

This is my own personal nvim config.
I keep this as backup in case I do anything stupid.

Intended for personal use but may work for others as well.
You are welcomed to fork and use my config.

Tested on termux(Android) and linux(ArchLinux) but there is no guarantee of stability or compatibility.
Everything may change at anytime.


I configured this with keen balance between features and performance .
The goal was to have a config that is simple and does more with less plugins and avoid redundancy altogether.

## ⚡️ Requirements

 Basic utils: `git`, `make`, `unzip`, 

- [fzf](https://github.com/junegunn/fzf): a command-line fuzzy finder.
- [viu](https://github.com/atanunq/viu): a terminal image viewer with native support for iTerm and Kitty.
- [fd](https://github.com/sharkdp/fd): a better version of the find utility.
- [ripgrep(rg)](https://github.com/BurntSushi/ripgrep): a better version of the grep utility.


- Nerdfont : for pretty text icon
- `tree-sitter-cli`: for installing parsers


on Termux Download a nerdfont, paste in ~/.termux, and rename to `font.ttf`.

## Adding Language Servers And Formatters

### Easy
Enable Mason which is disabled by default
Open `:Mason` and search for any desired lsp.
You could use `:LspInstall <lsp name>` as well.

### Hard
Manually Install LSPs globally using Package Manager ,npm or pip or installation method of preference.
WHY? ....

## ✨ Features

- Plugin management via [lazy.nvim](https://github.com/folke/lazy.nvim.git).

- Sessions support via [persistence].
- Colorscheme via [ayu],[githubTheme].
- Mapping hint via [which-key.nvim](https://github.com/folke/which-key.nvim).
- Git integration via [neogit](https://github.com/NeogitOrg/neogit), [vim-fugitive](https://github.com/tpope/vim-fugitive), [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim), [gitlinker.nvim](https://github.com/ruifm/gitlinker.nvim), [diffview.lua](https://github.com/sindrets/diffview.nvim), [mergetool.lua](https://github.com/samoshkin/vim-mergetool).
- Language server protocol (LSP) support via [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig).
- Code auto-completion via [nvim-cmp].
- Code commenting via [ts-comments.nvim](https://github.com/folke/ts-comments.nvim).
- Code formatting via [conform.nvim](https://github.com/stevearc/conform.nvim).
- Code highlighting via [ts-forge.nvim](https://github.com/reybits/ts-forge.nvim).
- Multicursor support via [multicursor.nvim](https://github.com/jake-stewart/multicursor.nvim).
- TMUX support via [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim).
- Markdown writing and previewing via [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) and [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim).

- Buffer name as ghost text in the top-right corner via [wisp.nvim](https://github.com/reybits/wisp.nvim).
- Blind typing trainer via [typr](https://github.com/nvzone/typr).
  
- Language Server manager via [mason.nvim](https://github.com/williamboman/mason.nvim).

### Optional

- FZF [fzf-lua](https://github.com/ibhagwan/fzf-lua).
- File tree explorer via [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim).
- Buffer navigation via [flash.nvim](https://github.com/folke/flash.nvim).

- LazyGit [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim).
- Octo [octo.nvim](https://github.com/pwntester/octo.nvim).
- Codeium [neocodeium](https://github.com/monkoose/neocodeium).
- Copilot Chat [CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim) with blink-cmp integration.
- AI chat via [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim).
- Marker Groups via [marker-groups.nvim](https://github.com/rachartier/jameswolensky/marker-groups.nvim).
- Folding nvim-ufo [nvim-ufo](https://github.com/kevinhwang91/nvim-ufo).

