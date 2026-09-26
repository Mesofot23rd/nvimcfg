local conditions = require 'custom.statusline_components.condition'
local utils = require 'custom.statusline_components.utils'
local hl = require 'custom.statusline_components.hl'
local env = require 'custom.statusline_components.env'

local M = {}

local Space = { provider = ' ' }

--------------------------------------------------------------------------------
-- MODE
--------------------------------------------------------------------------------

M.OSIcon = {
  provider = function() return ' ' .. utils.get_os_icon() .. '  ' end,
  hl = function() return { bg = hl.mode_bg(), fg = 'bg', bold = true } end,
}

M.ModeName = {
  provider = function()
    local mode = vim.fn.mode()
    return env.modes[mode] and env.modes[mode][1] or 'UNKNOWN '
  end,
  hl = function() return { bg = hl.mode_bg(), fg = 'bg', bold = true } end,
}

-- Flexible Mode component
M.Mode = function(opts)
  opts = opts or {}
  local children = {}
  if opts.os_icon ~= false then table.insert(children, M.OSIcon) end
  if opts.mode_name ~= false then table.insert(children, M.ModeName) end
  if #children == 0 then
    -- Just color mode
    return {
      provider = ' ',
      hl = function() return { bg = hl.mode_bg() } end,
    }
  end
  return children
end

--------------------------------------------------------------------------------
-- GIT
--------------------------------------------------------------------------------

M.GitBranch = {
  condition = conditions.is_git_repo,
  init = function(self) self.status_dict = vim.b.gitsigns_status_dict end,
  provider = function(self) return '  ' .. self.status_dict.head .. ' ' end,
  hl = { fg = 'git_branch_fg', bold = true },
}

M.GitDiff = {
  update = {
    'User',
    pattern = { 'GitSignsUpdate', 'GitSignsChanged', 'MiniDiffUpdated' },
  },
  condition = conditions.is_git_repo,
  init = function(self) self.status_dict = vim.b.gitsigns_status_dict end,
  {
    provider = function(self)
      local count = self.status_dict.added or 0
      return count > 0 and ('  ' .. count)
    end,
    hl = { fg = 'git_added' },
  },
  {
    provider = function(self)
      local count = self.status_dict.changed or 0
      return count > 0 and ('  ' .. count)
    end,
    hl = { fg = 'git_changed' },
  },
  {
    provider = function(self)
      local count = self.status_dict.removed or 0
      return count > 0 and ('  ' .. count)
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
    error_icon = utils.get_icon 'DiagnosticError',
    warn_icon = utils.get_icon 'DiagnosticWarn',
    info_icon = utils.get_icon 'DiagnosticInfo',
    hint_icon = utils.get_icon 'DiagnosticHint',
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
  condition = conditions.is_macro_recording,
  provider = function() return '  ' .. vim.fn.reg_recording() .. ' ' end,
  hl = { fg = 'macro_recording', bold = true },
  update = {
    'RecordingEnter',
    'RecordingLeave',
  },
}

M.FileFlags = {
  {
    condition = conditions.file_modified,
    provider = '[] ',
    hl = { fg = 'insert' },
  },
  {
    condition = conditions.file_read_only,
    provider = '  ',
    hl = { fg = 'command' },
  },
}

--------------------------------------------------------------------------------
-- FILE TYPE
--------------------------------------------------------------------------------

M.FileIcon = {
  init = function(self)
    local filename = vim.api.nvim_buf_get_name(0)
    local buftype = vim.api.nvim_get_option_value('buftype', { buf = 0 })
    if buftype == 'terminal' then
      self.icon = ' '
    else
      local extension = vim.fn.fnamemodify(filename, ':e')
      self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
    end
  end,

  provider = function(self) return self.icon and (self.icon .. '  ') end,

  hl = function(self) return { fg = self.icon_color } end,
}

M.FileTypeName = {
  provider = function()
    -- local buftype= vim.api.nvim_get_option_value('buftype', { buf = 0 }
    return vim.bo.filetype ~= '' and vim.bo.filetype or vim.api.nvim_get_option_value('buftype', { buf = 0 })
  end,
  hl = { fg = 'fg', bold = true },
}

M.FileType = function(opts)
  opts = opts or {}
  local children = {}
  if opts.icon ~= false then table.insert(children, M.FileIcon) end
  if opts.name ~= false then table.insert(children, M.FileTypeName) end
  return children
end

M.TerminalName = {
  -- we could add a condition to check that buftype == 'terminal'
  -- or we could do that later (see #conditional-statuslines below)
  provider = function()
    local terminal = require 'toggleterm.terminal'

    local tname, _ = vim.api.nvim_buf_get_name(0):gsub('.*:', '')
    return '   toggleterm #' .. terminal 'b:toggle_number'
  end,
  hl = { fg = 'fg', bold = true },
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

--------------------------------------------------------------------------------
-- VENV
--------------------------------------------------------------------------------

M.Venv = {
  condition = conditions.has_virtual_env,
  provider = function()
    local venv = vim.env.VIRTUAL_ENV or vim.env.CONDA_DEFAULT_ENV
    if venv then return ' [' .. vim.fn.fnamemodify(venv, ':t') .. '] ' end
  end,
  hl = { fg = 'lsp_active', bold = true },
}

--------------------------------------------------------------------------------
-- NAVIGATION
--------------------------------------------------------------------------------

M.Ruler = {
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
    sbar = { ' ', '▂', '▃', '▄', '▅', '▆', '▇', '█' },
  },
  provider = function(self)
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
    return string.rep(self.sbar[i], 2)
  end,
  hl = { fg = 'scrollbar' },
}

M.Navigation = {
  M.Percentage,
  M.Ruler,
  M.ScrollBar,
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

M.StatusColumn = {
  M.SignColumn,
  M.LineNumbers,
  M.FoldColumn,
}

--------------------------------------------------------------------------------
-- TABLINE
--------------------------------------------------------------------------------

M.FileName = {
  provider = function()
    local filename = vim.fn.expand '%:t'
    if filename == '' then filename = '[No Name]' end
    return ' ' .. filename .. ' '
  end,
  hl = { fg = 'fg', bold = true },
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

  init = function(self) self.icons = require('custom.icons').kinds end,

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
  hl = { fg = 'fg', bg = 'winbar_bg' },
}

return M
