return {
  -- - https://github.com/nvim-neo-tree/neo-tree.nvim
  'nvim-neo-tree/neo-tree.nvim',
  cmd = 'Neotree',
  lazy = false,
  dependencies = {
    { 'nvim-lua/plenary.nvim', lazy = true },
    { 'MunifTanjim/nui.nvim', lazy = true },
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('neo-tree').setup {
      close_if_last_window = true,
      add_blank_line_at_top = false,
      -- enable_git_status = false,
      hide_root_node = true,
      popup_border_style = 'rounded',
      sort_function = nil,

      clipboard = {
        sync = 'global', -- or "global"/"universal" to share a clipboard for each/all Neovim instance(s), respectively
      },

      source_selector = {
        winbar = true,
        content_layout = 'center',
        sources = {
          {
            source = 'filesystem',
          },
          {
            source = 'buffers',
          },
          {
            source = 'git_status',
          },
          {
            source = 'diagnostics',
          },
        },
      },

      window = {
        mappings = {
          ['<C-b>'] = 'close_window',
        },
      },

      filesystem = {
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
        use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
        -- instead of relying on nvim autocmd events.
      },
      default_component_configs = {
        name = { use_git_status_colors = false },
        git_status = {
          symbols = {
            -- Change type
            added = '✚', -- or "✚"
            modified = '', -- or ""
            deleted = '✖', -- this can only be used in the git_status source
            renamed = '󰁕', -- this can only be used in the git_status source
            -- Status type
            untracked = '',
            ignored = '',
            unstaged = '󰄱',
            staged = '',
            conflict = '',
          },
        },
      },
    }

    -- ----------------------------------------------------------------------------------------------------------------
    --NEOTREE

    -- vim.cmd [[nnoremap \ :Neotree reveal<cr>]]
    vim.keymap.set({ 'n', 'i' }, '<C-b>', '<cmd>Neotree toggle position=left<CR>', { noremap = true, silent = true }) -- focus file explorer
  end,
}
