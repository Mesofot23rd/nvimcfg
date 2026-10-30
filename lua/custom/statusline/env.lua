local M = {}

M.fallback_colors = {
  none = 'NONE',
  fg = '#abb2bf',
  bg = '#2c323c',
  white = '#c9c9c9',
  yellow = '#ffc021',
  cyan = '#56b6c2',
  green = '#47d864',
  orange = '#ff8800',
  magenta = '#c678dd',
  blue = '#51afef',
  red = '#ee2c4a',
  gray = '#5c6370',
  purple = '#c688eb',
  pink = '#eb7fdc',
}

local palette = {}

-- -----------------------------------------------------------------------------
-- Mode Definitions
-- -----------------------------------------------------------------------------
local modes = {
  ['n'] = { name = 'NORMAL', hl = 'StatusLineModeNormal' },
  ['no'] = { name = 'O-PEND', hl = 'StatusLineModeNormal' },
  ['nov'] = { name = 'O-PEND', hl = 'StatusLineModeNormal' },
  ['noV'] = { name = 'O-PEND', hl = 'StatusLineModeNormal' },
  ['no\22'] = { name = 'O-PEND', hl = 'StatusLineModeNormal' },
  ['niI'] = { name = 'NORMAL', hl = 'StatusLineModeNormal' },
  ['niR'] = { name = 'NORMAL', hl = 'StatusLineModeNormal' },
  ['niV'] = { name = 'NORMAL', hl = 'StatusLineModeNormal' },
  ['i'] = { name = 'INSERT', hl = 'StatusLineModeInsert' },
  ['ic'] = { name = 'INSERT', hl = 'StatusLineModeInsert' },
  ['ix'] = { name = 'INSERT', hl = 'StatusLineModeInsert' },
  ['v'] = { name = 'VISUAL', hl = 'StatusLineModeVisual' },
  ['vs'] = { name = 'VISUAL', hl = 'StatusLineModeVisual' },
  ['V'] = { name = 'V-LINE', hl = 'StatusLineModeVisual' },
  ['Vs'] = { name = 'V-LINE', hl = 'StatusLineModeVisual' },
  ['\22'] = { name = 'V-BLOCK', hl = 'StatusLineModeVisual' },
  ['\22s'] = { name = 'V-BLOCK', hl = 'StatusLineModeVisual' },
  ['s'] = { name = 'SELECT', hl = 'StatusLineModeVisual' },
  ['S'] = { name = 'S-LINE', hl = 'StatusLineModeVisual' },
  ['\19'] = { name = 'S-BLOCK', hl = 'StatusLineModeVisual' },
  ['R'] = { name = 'REPLACE', hl = 'StatusLineModeReplace' },
  ['Rc'] = { name = 'REPLACE', hl = 'StatusLineModeReplace' },
  ['Rx'] = { name = 'REPLACE', hl = 'StatusLineModeReplace' },
  ['Rv'] = { name = 'V-REPLACE', hl = 'StatusLineModeReplace' },
  ['c'] = { name = 'COMMAND', hl = 'StatusLineModeCommand' },
  ['cv'] = { name = 'EX', hl = 'StatusLineModeCommand' },
  ['ce'] = { name = 'EX', hl = 'StatusLineModeCommand' },
  ['r'] = { name = 'PROMPT', hl = 'StatusLineModeNormal' },
  ['rm'] = { name = 'MORE', hl = 'StatusLineModeNormal' },
  ['r?'] = { name = 'CONFIRM', hl = 'StatusLineModeNormal' },
  ['!'] = { name = 'SHELL', hl = 'StatusLineModeNormal' },
  ['t'] = { name = 'TERMINAL', hl = 'StatusLineModeTerminal' },
  ['nt'] = { name = 'TERMINAL', hl = 'StatusLineModeTerminal' },
}

M.icons = {
  -- Heirline-components - statusline
  ActiveLSP = '',
  ActiveTS = '',
  Environment = '',
  DiagnosticError = '',
  DiagnosticHint = '󰌵',
  DiagnosticInfo = '󰋼',
  DiagnosticWarn = '',
  SearchCount = '',
  MacroRecording = '',

  -- Git
  GitBranch = '',
  GitAdd = '',
  GitChange = '',
  GitDelete = '',

  -- Misc
  PathSeparator = '',
  BreadcrumbSeparator = '',

  --Operating systems
  Linux = ' ',
  MacOs = ' ',
  BSD = 'BSD ',
  Windows = ' ',
  Arch = ' ',
  Android = '󱚟 ',

  sep_icons = {
    default = { left = '', right = '' },
    round = { left = '', right = '' },
    block = { left = '█', right = '█' },
    arrow = { left = '', right = '' },
  },
}

return M
