local component = require 'custom.statusline_components.components'
local conditions = require 'custom.statusline_components.condition'
local hl = require 'custom.statusline_components.hl'

local M = {}

local Align = { provider = '%=' }
local Space = { provider = ' ' }

-- ============================================================================

local Active_STATUSLINE = {
  condition = conditions.is_active,
  hl = { fg = 'fg', bg = 'bg' },
  component.Mode { os_icon = true, mode_name = true },
  Space,
  component.GitBranch,
  component.FileFlags,
  component.GitDiff,
  Space,
  Space,
  component.Diagnostics,
  Align,
  component.MacroRecording,
  Space,
  component.FileType { icon = true, name = true },
  Align,
  component.LSPActive,
  Space,
  component.Venv,
  component.Percentage,
  Space,
  component.Ruler,
  Space,
  component.Mode { os_icon = false, mode_name = false }, -- Mode [just color]
}

-- ============================================================================

local Short_STATUSLINE = {
  condition = function() return conditions.is_active() and conditions.width_below(80) end,
  hl = { fg = 'fg', bg = 'bg' },
  component.Mode { os_icon = true, mode_name = false },
  Space,
  component.FileName,
  Align,
  component.Ruler,
  component.Percentage,
  Space,
  component.Mode { os_icon = false, mode_name = false },
}

-- ============================================================================

local Inactive_STATUSLINE = {
  condition = function() return not conditions.is_active() end,
  hl = { fg = 'fg', bg = 'winbar_bg' },
  Align,
  component.FileIcon,
  component.FileName,
  Align,
}

-- ============================================================================

local Neotree_STATUSLINE = {
  condition = function() return conditions.buffer_matches { filetype = { 'neo-tree' } } end,
  hl = { fg = 'fg', bg = 'bg' },
  component.Mode { os_icon = true, mode_name = false },
  Align,
  { provider = '󰙅 neo-tree ' },
  Align,
  component.ScrollBar,
}

-- ============================================================================

local Terminal_STATUSLINE = {
  condition = function()
    local buftype = vim.api.nvim_get_option_value('buftype', { buf = 0 })
    return buftype == 'terminal'
  end,

  hl = { fg = 'fg', bg = 'bg' },
  component.Mode { os_icon = true, mode_name = true },
  Align,
  { provider = '  toggleterm # ' },
  -- component.TerminalName,
  Align,
  component.ScrollBar,
}

-- ============================================================================

M.STATUSLINE = {
  fallthrough = false,
  Inactive_STATUSLINE,
  Neotree_STATUSLINE,
  Terminal_STATUSLINE,

  Short_STATUSLINE, -- Check for small window before full active statusline
  Active_STATUSLINE,
}

-- ============================================================================

M.TABLINE = {
  hl = { fg = 'tabline_fg', bg = 'tabline_bg' },

  -- 1. FileName [without icon]
  component.FileName,

  -- 2. Breadcrumbs
  component.Breadcrumbs,
}

-- ============================================================================

M.STATUSCOLUMN = {
  component.FoldColumn,
  component.LineNumbers,
  component.SignColumn,
}

return M
