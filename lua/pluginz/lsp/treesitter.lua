return {
  'nvim-treesitter/nvim-treesitter',
  event = 'User BaseDefered',
  cmd = {
    'TSBufDisable',
    'TSBufEnable',
    'TSBufToggle',
    'TSDisable',
    'TSEnable',
    'TSToggle',
    'TSInstall',
    'TSInstallInfo',
    'TSInstallSync',
    'TSModuleInfo',
    'TSUninstall',
    'TSUpdate',
    'TSUpdateSync',
  },
  lazy = false,
  build = ':TSUpdate',
  opts = {

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    auto_install = true,

    ensure_installed = {
      'c',
      'cpp',
      'cmake',
      'make',
      'javascript',
      'typescript',
      'jsx',
      'tsx',
      'kotlin',
      'angular',
      'comment',
      'fish',
      'bash',
      'lua',
      'python',
      'html',
      'css',
      'xml',
      'json',
      'json5',
      'yaml',
      'toml',
      'markdown',
      'markdown_inline',
      'vim',
      'vimdoc',
      'query',
      'diff',
      'gitcommit',
      'gitignore',
    },

    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
      disable = function(lang, buf)
        local max_filesize = 500 * 1024 -- 500 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
    },
    matchup = {
      enable = true,
      enable_quotes = true,
      disable = function(lang, buf)
        local max_filesize = 1000 * 1024 -- 1 MB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
    },
    incremental_selection = { enable = true },
    indent = {
      enable = true,
    },
  },

  config = function(_, opts)
    require('nvim-treesitter').setup(opts)

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'rust', 'javascript', 'typescript', 'jsx', 'tsx', 'lua', 'python' },
      callback = function()
        vim.treesitter.start()
      end,
    })
  end,
}
