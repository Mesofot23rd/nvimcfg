return {
  'G00380316/live-server.nvim',
  cmd = 'LiveServer',
  keys = {
    { '<leader>rs', '<Cmd>LiveServer toggle<CR>', desc = 'Toggle live server' },
    { '<leader>rm', '<Cmd>LiveServer<CR>', desc = 'LiveServer manager' },
    { '<leader>ro', '<Cmd>LiveServer open<CR>', desc = 'Open in browser' },
    { '<leader>rl', '<Cmd>LiveServer logs<CR>', desc = 'LiveServer logs' },
    { '<leader>re', '<Cmd>LiveServer expose<CR>', desc = 'LiveServer expose' },
  },
}
