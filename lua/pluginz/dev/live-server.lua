return {
  'G00380316/live-server.nvim',
  lazy = false, -- Recommended to ensure VimLeave cleanup always runs
  config = function()
    -- require('live_server').setup {
    --   browser_sync_port = 3000,
    --   live_server_port = 8080,
    --   files_to_watch = '"*.html, *.css, *.js"',
    --   auto_open_browser = true, -- Set to false to disable
    -- }

    vim.keymap.set(
      'n',
      '<leader>rs',
      function() require('live_server.core').toggle_live_server() end,
      { desc = '[L]iveServer' }
    )

    vim.keymap.set(
      'n',
      '<leader>rb',
      function() require('live_server.core').toggle_browser_sync() end,
      { desc = '[B]rowserSync' }
    )

    vim.keymap.set(
      'n',
      '<leader>rl',
      function() require('live_server.ui').list_servers() end,
      { desc = '[L]iveServers list' }
    )
  end,
}
