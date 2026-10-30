return {
  -- - https://github.com/nvim-neo-tree/neo-tree.nvim
  'nvim-neo-tree/neo-tree.nvim',
  cmd = 'Neotree',
  lazy = false, -- neo-tree will lazily load itself
  dependencies = {
    { 'nvim-lua/plenary.nvim', lazy = true },
    { 'MunifTanjim/nui.nvim', lazy = true },
    'nvim-tree/nvim-web-devicons',
  },

  ----------------------------------------------------------------------------------------------------------------
  --MAPPINGS

  keys = {
    { '<C-b>', '<cmd>Neotree toggle position=left<CR>', desc = 'Toggle File Explorer', mode = { 'n', 'i' } }, -- focus file explorer
    { '-', '<cmd>Neotree toggle position=float<CR>', desc = 'Toggle File Explorer' },
  },

  ----------------------------------------------------------------------------------------------------------------
  config = function()
    require('neo-tree').setup {
      close_if_last_window = true,
      add_blank_line_at_top = false,
      auto_clean_after_session_restore = true,
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
          -- {
          --   source = 'git_status',
          -- },
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
      },
    }
  end,
}
