local function get_root()
  local bufpath = vim.api.nvim_buf_get_name(0)
  if bufpath == '' then
    return vim.fn.getcwd()
  end
  return vim.fs.root(bufpath, '.git') or vim.fn.getcwd()
end

return {
  'ibhagwan/fzf-lua',
  cmd = { 'FzfLua' },
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {

    winopts = {
      height = 0.85,
      width = 0.80,
      row = 0.35,
      col = 0.50,
      border = 'rounded',
      backdrop = 60,
      preview = {
        layout = 'flex',
      },
    },
    files = {
      prompt = 'files> ',
      fd_opts = '--type f --color=never --exclude .git',
      git_icons = true,
    },
    live_grep = {
      rg_opts = "--color=never --column --hidden --no-heading --glob '!.git'",
    },
    help_tags = {
      silent = true,
    },
    defaults = {
      fzf_opts = {
        ['--layout'] = 'default',
      },
    },
  },
  keys = {
    -- Files / Grep
    { '<leader>ff', '<Cmd>FzfLua files<CR>', desc = 'Find files[fzf]' },
    { '<leader>fg', '<Cmd>FzfLua git_files<CR>', desc = 'Find Git files[fzf]' },
    { '<leader>fr', '<Cmd>FzfLua live_grep<CR>', desc = 'Live grep[fzf]' },
    { '<leader>fb', '<Cmd>FzfLua buffers<CR>', desc = 'Find Buffers[fzf]' },
    { '<leader>fh', '<Cmd>FzfLua help_tags<CR>', desc = 'Find Help tags[fzf]' },
    -- { '<leader>fo', '<Cmd>FzfLua oldfiles<CR>', desc = 'Recent files' },
    { '<leader>f/', '<Cmd>FzfLua blines<CR>', desc = 'Search current buffer[fzf]' },
    -- { '<leader>fc', '<Cmd>FzfLua colorschemes<CR>', desc = 'Colorschemes' },
    -- { '<leader>fq', '<Cmd>FzfLua quickfix<CR>', desc = 'Quickfix' },
    { '<leader>ft', '<Cmd>TodoFzfLua<CR>', desc = 'Find TODOs[fzf]' },

    -- Diagnostics
    -- { 'gl', '<Cmd>FzfLua diagnostics_workspace<CR>', desc = 'Workspace diagnostics' },
    -- { '<leader>fd', '<Cmd>FzfLua diagnostics_document<CR>', desc = 'Buffer diagnostics' },

    -- Word Search
    {
      '<leader>fw',
      function()
        require('fzf-lua').grep_cword()
      end,
      desc = 'Search word under cursor[fzf]',
    },
    {
      '<leader>fW',
      function()
        require('fzf-lua').grep_cWORD()
      end,
      desc = 'Search WORD under cursor[fzf]',
    },

    -- Git
    {
      '<leader>gs',
      function()
        require('fzf-lua').git_status { cwd = get_root() }
      end,
      desc = 'Git status[fzf]',
    },
    { '<leader>gc', '<Cmd>FzfLua git_commits<CR>', desc = 'Git commits[fzf]' },
    { '<leader>gb', '<Cmd>FzfLua git_branches<CR>', desc = 'Git branches[fzf]' },

    -- LSP
    -- { 'gd', '<Cmd>FzfLua lsp_definitions<CR>', desc = 'Definitions' },
    -- { 'gr', '<Cmd>FzfLua lsp_references<CR>', desc = 'References' },
    -- { 'gi', '<Cmd>FzfLua lsp_implementations<CR>', desc = 'Implementations' },
    -- { '<leader>fca', '<Cmd>FzfLua lsp_code_actions<CR>', mode = { 'n', 'x' }, desc = 'Code action' },
    -- { '<leader>fcs', '<Cmd>FzfLua lsp_document_symbols<CR>', desc = 'Document symbols' },
    -- { '<leader>fcS', '<Cmd>FzfLua lsp_workspace_symbols<CR>', desc = 'Workspace symbols' },
  },

  config = function()
    require('fzf-lua').setup {
      ui_select = true,
    }

    -- You can easily open any search results in **Trouble**, by defining a custom action:
    local config = require 'fzf-lua.config'
    local actions = require('trouble.sources.fzf').actions
    config.defaults.actions.files['ctrl-o'] = actions.open
  end,
}
