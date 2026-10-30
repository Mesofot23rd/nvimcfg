local conditions = require 'heirline.conditions'
local cond = require 'custom.statusline.condition'
local hl = require 'custom.statusline.hl'
local env = require 'custom.statusline.env'
local icons = require 'custom.icons'

local M = {}
local Align = { provider = '%=' }
local Space = { provider = ' ' }

--------------------------------------------------------------------------------
-- MODE
--------------------------------------------------------------------------------

M.OSIcon = {
  provider = function()
    local os_uname = (vim.uv or vim.loop).os_uname()
    local icon

    if vim.fn.has 'mac' == 1 then
      icon = env.icons.MacOs
    elseif vim.fn.has 'win32' == 1 then
      icon = env.icons.Windows
    elseif vim.fn.has 'Android' == 1 then
      icon = env.icons.Android
    elseif os_uname.sysname:match 'Linux' then
      icon = os_uname.release:lower():find 'arch' and env.icons.Arch or env.icons.Linux
    end

    return icon and (' ' .. icon .. ' ') or ''
  end,
}

M.ModeName = {
  provider = function()
    local mode = vim.fn.mode()
    return env.modes[mode] and env.modes[mode][1] or 'UNKNOWN '
  end,
}

--------------------------------------------------------------------------------
-- GIT
--------------------------------------------------------------------------------

M.GitBranch = {
  condition = conditions.is_git_repo,
  init = function(self) self.status_dict = vim.b.gitsigns_status_dict end,
  provider = function(self)
    local head = (self.status_dict and self.status_dict.head) or vim.b.gitsigns_head
    return head and (icons.GitBranch .. head .. ' ') or ''
  end,
  hl = { fg = 'git_branch_fg', bold = true },
}

M.GitDiff = {
  update = {
    pattern = { 'GitSignsUpdate', 'GitSignsChanged', 'MiniDiffUpdated' },
  },
  condition = conditions.is_git_repo,
  init = function(self) self.status_dict = vim.b.gitsigns_status_dict or {} end,
  {
    provider = function(self)
      local count = self.status_dict.added or 0
      return count > 0 and (icons.GitAdd .. count .. ' ')
    end,
    hl = { fg = 'git_added' },
  },
  {
    provider = function(self)
      local count = self.status_dict.changed or 0
      return count > 0 and (icons.GitChange .. count .. ' ')
    end,
    hl = { fg = 'git_changed' },
  },
  {
    provider = function(self)
      local count = self.status_dict.removed or 0
      return count > 0 and (icons.GitDelete .. count .. ' ')
    end,
    hl = { fg = 'git_removed' },
  },
}

--------------------------------------------------------------------------------
-- DIAGNOSTICS
--------------------------------------------------------------------------------

M.Diagnostics = {
  condition = conditions.has_diagnostics,
  static = {
    error_icon = icons.DiagnosticError,
    warn_icon = icons.DiagnosticWarn,
    info_icon = icons.DiagnosticInfo,
    hint_icon = icons.DiagnosticHint,
    -- error_icon = utils.get_icon 'DiagnosticError',
    -- warn_icon = utils.get_icon 'DiagnosticWarn',
    -- info_icon = utils.get_icon 'DiagnosticInfo',
    -- hint_icon = utils.get_icon 'DiagnosticHint',
  },
  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  end,
  update = { 'DiagnosticChanged', 'BufEnter' },
  {
    provider = function(self) return self.errors > 0 and (self.error_icon .. ' ' .. self.errors .. ' ') end,
    hl = { fg = 'diag_ERROR' },
  },
  {
    provider = function(self) return self.warnings > 0 and (self.warn_icon .. ' ' .. self.warnings .. ' ') end,
    hl = { fg = 'diag_WARN' },
  },
  {
    provider = function(self) return self.info > 0 and (self.info_icon .. ' ' .. self.info .. ' ') end,
    hl = { fg = 'diag_INFO' },
  },
  {
    provider = function(self) return self.hints > 0 and (self.hint_icon .. ' ' .. self.hints .. ' ') end,
    hl = { fg = 'diag_HINT' },
  },
}

--------------------------------------------------------------------------------
-- COMMAND INFO
--------------------------------------------------------------------------------

M.MacroRecording = {
  condition = cond.is_macro_recording,
  provider = function() return icons.MacroRecording .. vim.fn.reg_recording() .. ' ' end,
  hl = { fg = 'macro_recording', bold = true },
  update = {
    'RecordingEnter',
    'RecordingLeave',
  },
}

M.FileFlags = {
  {
    condition = cond.file_modified,
    provider = '[] ',
    hl = { fg = 'insert' },
  },
  {
    condition = cond.file_read_only,
    provider = '  ',
    hl = { fg = 'command' },
  },
}

--------------------------------------------------------------------------------
-- FILE (ICON,TYPE,NAME,ENCODING,SIZE,LASTMODIFIED)
--------------------------------------------------------------------------------

M.FileIcon = {
  init = function(self)
    local filename = vim.api.nvim_buf_get_name(0)
    local buftype = vim.api.nvim_get_option_value('buftype', { buf = 0 })
    if buftype == 'terminal' then
      self.icon = icons.Terminal
    else
      local extension = vim.fn.fnamemodify(filename, ':e')
      self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
    end
  end,

  provider = function(self) return self.icon and (self.icon .. ' ') end,

  hl = function(self) return { fg = self.icon_color } end,
}

M.FileType = {
  provider = function()
    return vim.bo.filetype ~= '' and vim.bo.filetype or vim.api.nvim_get_option_value('buftype', { buf = 0 })
  end,
  hl = { fg = 'fg', bold = true },
}

M.FileName = {
  provider = function()
    local filename = vim.fn.expand '%:t'
    if filename == '' then filename = '[No Name]' end
    return ' ' .. filename .. ' '
  end,
  hl = { fg = 'fg' },
}

M.FileEncoding = {
  provider = function()
    local enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc -- :h 'enc'
    return enc ~= 'utf-8' and enc:upper()
  end,
}

M.FileSize = {
  provider = function()
    -- stackoverflow, compute human readable file size
    local suffix = { 'b', 'k', 'M', 'G', 'T', 'P', 'E' }
    local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
    fsize = (fsize < 0 and 0) or fsize
    if fsize < 1024 then return fsize .. suffix[1] end
    local i = math.floor((math.log(fsize) / math.log(1024)))
    return string.format('%.2g%s', fsize / math.pow(1024, i), suffix[i + 1])
  end,
}

M.FileLastModified = {
  provider = function()
    local ftime = vim.fn.getftime(vim.api.nvim_buf_get_name(0))
    return (ftime > 0) and os.date('%c', ftime)
  end,
}

--------------------------------------------------------------------------------
-- LSP
--------------------------------------------------------------------------------

M.LSPActive = {
  condition = conditions.lsp_attached,
  update = { 'LspAttach', 'LspDetach', 'BufEnter', 'FileType', 'VimResized' },
  provider = function()
    local names = {}
    for _, server in pairs(vim.lsp.get_clients { bufnr = 0 }) do
      table.insert(names, server.name)
    end
    return ' [' .. table.concat(names, ' ') .. ']'
  end,

  hl = { fg = 'lsp_active', bold = true },
}

-- M.LSPMessages = {
--   provider = require('lsp-status').status,
--   hl = { fg = 'gray' },
-- }

--------------------------------------------------------------------------------
-- VENV
--------------------------------------------------------------------------------

M.Venv = {
  condition = cond.has_virtual_env,
  provider = function()
    local venv = vim.env.VIRTUAL_ENV or vim.env.CONDA_DEFAULT_ENV
    if venv then return ' [' .. vim.fn.fnamemodify(venv, ':t') .. '] ' end
  end,
  hl = { fg = 'lsp_active', bold = true },
}

--------------------------------------------------------------------------------
-- CURSOR POSITION
--------------------------------------------------------------------------------

M.Ruler = {
  -- %l = current line number
  -- %L = number of lines in the buffer
  -- %c = column number
  -- %P = percentage through file of displayed window
  provider = ' %l:%c',
  hl = { bold = true },
}

M.Percentage = {
  provider = function()
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    if curr_line == 1 then
      return ' Top'
    elseif curr_line == lines then
      return ' Bot'
    else
      return ' %P'
    end
  end,

  hl = { bold = true },
}

M.ScrollBar = {
  static = {
    -- sbar = { ' ', '▂', '▃', '▄', '▅', '▆', '▇', '█' },
    sbar = { '_', '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' },
  },
  provider = function(self)
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
    return string.rep(self.sbar[i], 2)
  end,

  hl = { fg = 'scrollbar' },
}

--------------------------------------------------------------------------------
-- STATUSCOLUMN
--------------------------------------------------------------------------------

M.SignColumn = {
  provider = '%s',
}

M.LineNumbers = {
  provider = '%l ',
}

M.FoldColumn = {
  provider = '%C',
}

--------------------------------------------------------------------------------
-- TABLINE
--------------------------------------------------------------------------------
M.CloseButton = {
  condition = cond.file_modified,
  -- a small performance improvement:
  -- re register the component callback only on layout/buffer changes.
  update = { 'WinNew', 'WinClosed', 'BufEnter' },

  {
    provider = function()
      if cond.file_modified then
        return icons.FileModified
      else
        return icons.FileClose
      end
    end,
    hl = { fg = 'tabline_fg' },
    on_click = {
      minwid = function() return vim.api.nvim_get_current_win() end,
      callback = function(_, minwid) vim.api.nvim_win_close(minwid, true) end,
      name = 'heirline_winbar_close_button',
    },
  },
}
--------------------------------------------------------------------------------
-- BREADCRUMBS
--------------------------------------------------------------------------------

M.Breadcrumbs = {
  condition = function()
    local ok, aerial = pcall(require, 'aerial')
    return ok
  end,

  update = { 'CursorMoved', 'CursorMovedI', 'BufEnter', 'WinEnter', 'ModeChanged', 'TextChanged', 'TextChangedI' },

  init = function(self) self.icons = icons.kinds end,

  provider = function(self)
    local ok, aerial = pcall(require, 'aerial')
    if not ok then return '' end

    local symbols = aerial.get_location(true)
    if symbols and #symbols > 0 then
      local parts = {}
      for _, symbol in ipairs(symbols) do
        local icon = self.icons[symbol.kind] or ''
        table.insert(parts, icon .. symbol.name)
      end
      return '  ' .. table.concat(parts, '  ') .. ' '
    end
    -- For debugging: show something if aerial is active but no symbols found
    -- return '  '
    return ''
  end,
  hl = { fg = 'fg', bg = 'tabline_bg' },
}

-- FLEXIBLE COMPONENTS
-- Default: OS icon on the current mode color. Set `mode_name = true` to also
-- show the mode name, or `os_icon = false` to get a plain mode-colored block.
M.Mode = function(opts)
  opts = opts or {}
  local children = {}
  if opts.os_icon ~= false then table.insert(children, M.OSIcon) end
  if opts.mode_name then table.insert(children, M.ModeName) end

  local component = {
    hl = function() return { bg = hl.mode_bg(), bold = true } end,
  }

  if #children == 0 then
    component.provider = ' '
  else
    for _, child in ipairs(children) do
      table.insert(component, child)
    end
  end

  return component
end

-- Build a file component from any of: icon, type, name, encoding, size,
-- last_modified. Example: M.File { icon = true, name = true }
M.File = function(opts)
  opts = opts or {}
  local children = {}

  if opts.icon then table.insert(children, M.FileIcon) end
  if opts.type then table.insert(children, M.FileType) end
  if opts.name then table.insert(children, M.FileName) end
  if opts.encoding then table.insert(children, M.FileEncoding) end
  if opts.size then table.insert(children, M.FileSize) end
  if opts.last_modified then table.insert(children, M.FileLastModified) end

  return children
end

-- ============================================================================

local Active_STATUSLINE = {
  condition = conditions.is_active,
  hl = { bg = 'bg' },
  M.Mode { os_icon = true, mode_name = true },
  Space,
  M.GitBranch,
  M.FileFlags,
  M.GitDiff,
  Space,
  M.Diagnostics,
  Align,
  M.MacroRecording,
  Space,
  M.File { icon = true, type = true },
  Align,
  M.LSPActive,
  Space,
  M.Venv,
  M.Percentage,
  Space,
  M.Ruler,
  Space,
  M.Mode { os_icon = false }, -- Mode [just color]
}

-- ============================================================================

local Medium_STATUSLINE = {
  condition = function() return conditions.is_active() and not conditions.width_percent_below(100, 1) end,
  hl = { fg = 'bg' },
  M.Mode { os_icon = true, mode_name = true },
  M.Diagnostics,
  Align,
  M.LSPActive,
  M.Ruler,
  M.Percentage,
  Space,
  M.Mode { os_icon = false },
}

-- ============================================================================

local Short_STATUSLINE = {
  condition = function() return conditions.is_active() and not conditions.width_percent_below(80, 1) end,
  hl = { fg = 'bg' },
  M.Mode { os_icon = true, mode_name = true },
  Align,
  M.Ruler,
  M.Percentage,
  Space,
  M.Mode { os_icon = false },
}

-- ============================================================================

local Inactive_STATUSLINE = {
  condition = conditions.is_not_active,
  hl = { fg = 'bg' },
  Align,
  -- M.File { icon = true, name = true },
  -- Align,
}

-- ============================================================================

local Neotree_STATUSLINE = {
  condition = function() return conditions.buffer_matches { filetype = { 'neo-tree' } } end,
  hl = { bg = 'bg' },
  M.Mode { os_icon = true },
  Align,
  { provider = '󰙅 neo-tree ' },
  Align,
  M.ScrollBar,
}

-- ============================================================================

local Terminal_STATUSLINE = {
  condition = function() return conditions.buffer_matches { buftype = { 'terminal' } } end,
  hl = { bg = 'bg' },
  M.Mode { os_icon = true, mode_name = true },
  Align,
  M.File { icon = true, name = true },
  Align,
  M.ScrollBar,
}

-- ============================================================================

M.STATUSLINE = {
  fallthrough = false,
  Neotree_STATUSLINE,
  Terminal_STATUSLINE,
  Inactive_STATUSLINE,

  Short_STATUSLINE, -- Check for small window before full active statusline
  Medium_STATUSLINE,
  Active_STATUSLINE,
}

-- ============================================================================

M.TABLINE = {
  hl = { bg = 'tabline_bg' },

  M.File { name = true },
  M.CloseButton,
}

-- ============================================================================
M.WINBAR = {
  hl = { bg = 'winbar_bg' },
  M.Breadcrumbs,
}

-- ============================================================================

M.STATUSCOLUMN = {
  M.FoldColumn,
  M.LineNumbers,
  M.SignColumn,
}
return M
