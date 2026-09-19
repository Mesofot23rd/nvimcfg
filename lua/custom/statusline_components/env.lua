local M = {}

local default_sep_icons = {
  default = { left = '', right = '' },
  round = { left = '', right = '' },
  block = { left = '█', right = '█' },
  arrow = { left = '', right = '' },
}

M.fallback_colors = {
  none = 'NONE',
  fg = '#abb2bf',
  bg = '#1e222a',
  dark_bg = '#2c323c',
  blue = '#61afef',
  green = '#98c379',
  grey = '#5c6370',
  bright_grey = '#777d86',
  dark_grey = '#5c5c5c',
  orange = '#ff9640',
  purple = '#c678dd',
  bright_purple = '#a9a1e1',
  red = '#e06c75',
  bright_red = '#ec5f67',
  white = '#c9c9c9',
  yellow = '#e5c07b',
  bright_yellow = '#ebae34',
}

M.modes = {
  ['n'] = { 'NORMAL ', 'normal' },
  ['no'] = { 'OP ', 'normal' },
  ['nov'] = { 'OP ', 'normal' },
  ['noV'] = { 'OP ', 'normal' },
  ['no\22'] = { 'OP ', 'normal' },
  ['niI'] = { 'NORMAL ', 'normal' },
  ['niR'] = { 'NORMAL ', 'normal' },
  ['niV'] = { 'NORMAL ', 'normal' },
  ['i'] = { 'INSERT ', 'insert' },
  ['ic'] = { 'INSERT ', 'insert' },
  ['ix'] = { 'INSERT ', 'insert' },
  ['t'] = { 'TERMINAL ', 'terminal' },
  ['nt'] = { 'TERMINAL ', 'terminal' },
  ['v'] = { 'VISUAL ', 'visual' },
  ['vs'] = { 'VISUAL ', 'visual' },
  ['V'] = { 'V-LINE ', 'visual' },
  ['Vs'] = { 'V-LINE ', 'visual' },
  ['\22'] = { 'V-BLOCK ', 'visual' },
  ['\22s'] = { 'V-BLOCK ', 'visual' },
  ['R'] = { 'REPLACE ', 'replace' },
  ['Rc'] = { 'REPLACE ', 'replace' },
  ['Rx'] = { 'REPLACE ', 'replace' },
  ['Rv'] = { 'V-REPLACE ', 'replace' },
  ['s'] = { 'V-SELECT ', 'visual' },
  ['S'] = { 'V-SELECT ', 'visual' },
  ['\19'] = { 'V-BLOCK ', 'visual' },
  ['c'] = { 'COMMAND ', 'command' },
  ['cv'] = { 'COMMAND ', 'command' },
  ['ce'] = { 'COMMAND ', 'command' },
  ['r'] = { 'PROMPT ', 'inactive' },
  ['rm'] = { 'MORE ', 'inactive' },
  ['r?'] = { 'CONFIRM ', 'inactive' },
  ['!'] = { 'SHELL ', 'inactive' },
  ['null'] = { 'null ', 'inactive' },
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
}

-- Buffer matchers for conditions
M.buf_matchers = {
  buftype = function(pattern_list, bufnr)
    return vim.tbl_contains(pattern_list, vim.bo[bufnr or 0].buftype)
  end,
  filetype = function(pattern_list, bufnr)
    return vim.tbl_contains(pattern_list, vim.bo[bufnr or 0].filetype)
  end,
  bufname = function(pattern_list, bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr or 0)
    for _, pattern in ipairs(pattern_list) do
      if name:match(pattern) then
        return true
      end
    end
    return false
  end,
}

return M
