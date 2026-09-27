-- ### Icons

-- DESCRIPTION:
-- Here you can change the icons displayed in NormalNvim.
--
-- If you can't see the default icons:
-- Install nerd fonts and set it as your term font: https://www.nerdfonts.com/

--    Sections:
--      -> which-key
--      -> heirline-components (tabline)
--      -> heirline-components (winbar)
--      -> heirline-components (statuscolumn)
--      -> heirline-components (statusline)
--      -> heirline-components (misc)
--      -> Neotree
--      -> Git
--      -> DAP
--      -> Telescope
--      -> Nvim-lightbulb
--      -> Alpha
--      -> Mason
--      -> Render-markdown

return {
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

  --- Diagnostics
  Error = '',
  Warning = '',
  Info = '',
  Hint = '',
  Ok = '',

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

  Kinds = {
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
}
