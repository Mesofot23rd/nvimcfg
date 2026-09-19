return {
  files = {
    enabled = true, -- show file icons
    dir = '󰉋 ',
    dir_open = '󰝰 ',
    file = '󰈔 ',
  },
  keymaps = {
    nowait = '󰓅 ',
  },
  ui = {
    live = '󰐰 ',
    hidden = 'h',
    ignored = 'i',
    follow = 'f',
    selected = '● ',
    unselected = '○ ',
    -- selected = " ",
  },
  tree = { vertical = '│ ', middle = '├╴', last = '└╴' },
  undo = { saved = ' ' },
  diagnostics1 = {
    error = '', -- nf-fa-times \uf00d
    warning = '', -- nf-fa-warning \uf071
    info = '', -- nf-fa-info_circle \uf05a
    hint = '', -- nf-fa-bell \uf0f3
    ok = '', -- nf-fa-check \uf00c
  },
  diagnostics = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' },
  lsp = { unavailable = '', enabled = ' ', disabled = ' ', attached = '󰖩 ' },
  window = {
    -- window border options: single,double,rounded,solid,shadow,bold,none
    border = 'rounded',

    -- single border chars
    -- border_chars = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" }, -- double
    -- border_chars = { "┌", "─", "┐", "│", "┘", "─", "└", "│" }, -- single
    border_chars = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }, -- rounded
    -- border_chars = { " ", " ", " ", " ", " ", " ", " ", " " }, -- none
    -- border_chars = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" }, -- bold

    blend = 15,
  },
  kinds = {
    Array = ' ',
    Boolean = '󰨙 ',
    Class = ' ',
    Color = ' ',
    Control = ' ',
    Collapsed = ' ',
    Constant = '󰏿 ',
    Constructor = ' ',
    Copilot = ' ',
    Enum = ' ',
    EnumMember = ' ',
    Event = ' ',
    Field = ' ',
    File = ' ',
    Folder = ' ',
    Function = '󰊕 ',
    Interface = ' ',
    Key = ' ',
    Keyword = ' ',
    Method = '󰊕 ',
    Module = ' ',
    Namespace = '󰦮 ',
    Null = ' ',
    Number = '󰎠 ',
    Object = ' ',
    Operator = ' ',
    Package = ' ',
    Property = ' ',
    Reference = ' ',
    Snippet = '󱄽 ',
    String = ' ',
    Struct = '󰆼 ',
    Text = ' ',
    TypeParameter = ' ',
    Unit = ' ',
    Unknown = ' ',
    Value = ' ',
    Variable = '󰀫 ',
  },

  -- Which-key
  Debugger = '',
  Run = '󰑮',
  Find = '',
  Session = '󱂬',
  Sort = '󰒺',
  Buffer = '󰓩',
  Terminal = '',
  UI = '',
  Test = '󰙨',
  Packages = '󰏖',
  Docs = '',
  Git = '󰊢',
  LSP = '',

  -- Heirline-components - tabline
  BufferClose = '󰅖',
  FileModified = '',
  FileReadOnly = '',
  ArrowLeft = '',
  ArrowRight = '',
  TabClose = '󰅙',

  -- Heirline-components - winbar
  CompilerPlay = '',
  CompilerStop = '',
  CompilerRedo = '',
  NeoTree = '',
  Aerial = '',
  ZenMode = '󰰶',
  BufWrite = '',
  BufWriteAll = '',
  Ellipsis = '…',
  BreadcrumbSeparator = '',

  -- Heirline-components - statuscolumn
  FoldClosed = '',
  FoldOpened = '',
  FoldSeparator = ' ',

  -- Heirline-components - statusline
  ActiveLSP = '',
  ActiveTS = '',
  Environment = '',
  DiagnosticError = '',
  DiagnosticHint = '󰌵',
  DiagnosticInfo = '󰋼',
  DiagnosticWarn = '',
  LSPLoading1 = '',
  LSPLoading2 = '󰀚',
  LSPLoading3 = '',
  SearchCount = '',
  MacroRecording = '',
  ToggleResults = '󰑮',

  -- Heirline-components - misc
  Paste = '󰅌',
  PathSeparator = '',

  -- Neotree
  FolderClosed = '',
  FolderEmpty = '',
  FolderOpen = '',
  Diagnostic = '󰒡',
  DefaultFile = '󰈙',

  -- Git
  git = {
    commit = '󰜘 ', -- used by git log
    staged = '●', -- staged changes. always overrides the type icons
    added = '',
    deleted = '',
    ignored = ' ',
    modified = '○',
    renamed = '',
    unmerged = ' ',
    untracked = '?',
  },

  GitBranch = '',
  GitAdd = '',
  GitChange = '',
  GitDelete = '',
  GitConflict = '',
  GitIgnored = '◌',
  GitRenamed = '➜',
  GitSign = '▎',
  GitStaged = '✓',
  GitUnstaged = '✗',
  GitUntracked = '★',

  -- DAP
  DapBreakpoint = '',
  DapBreakpointCondition = '',
  DapBreakpointRejected = '',
  DapLogPoint = '.>',
  DapStopped = '󰁕',

  -- Telescope
  PromptPrefix = '❯',

  -- Nvim-lightbulb
  Lightbulb = '💡',

  -- Alpha
  GreeterNew = '📄',
  GreeterRecent = '🌺',
  GreeterYazi = '🦆',
  GreeterSessions = '🔎',
  GreeterProjects = '💼',
  GreeterPlug = '',

  -- Mason
  MasonInstalled = '✓',
  MasonUninstalled = '✗',
  MasonPending = '⟳',

  -- Render-markdown
  RenderMarkdown = { ' ', ' ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
}
