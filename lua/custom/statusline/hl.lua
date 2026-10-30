local M = {}
local env = require 'custom.statusline.env'

--- Get the highlight background color of the lualine theme for the current colorscheme.
function M.lualine_mode(mode, fallback)
  if not vim.g.colors_name then return fallback end
  local lualine_avail, lualine = pcall(require, 'lualine.themes.' .. vim.g.colors_name)
  local lualine_opts = lualine_avail and lualine[mode]
  return lualine_opts and type(lualine_opts.a) == 'table' and lualine_opts.a.bg or fallback
end

--- Get the foreground color group for the current mode.
function M.mode_bg()
  local mode = vim.fn.mode()
  return env.modes[mode] and env.modes[mode][2] or 'normal'
end

local function to_hex(color, fallback)
  if type(color) == 'number' then
    return string.format('#%06x', color)
  elseif type(color) == 'string' and color ~= '' then
    return color
  end
  return fallback or 'NONE'
end

--- Get highlight properties for a given highlight name.
function M.get_hlgroup(name, fallback)
  if vim.fn.hlexists(name) == 1 then
    local hl = vim.api.nvim_get_hl(0, { name = name, link = true })
    if hl.reverse then
      hl.fg, hl.bg = hl.bg, hl.fg
    end
    local res = {}
    res.fg = to_hex(hl.fg, fallback and fallback.fg)
    res.bg = to_hex(hl.bg, fallback and fallback.bg)
    return res
  end
  return fallback or { fg = 'NONE', bg = 'NONE' }
end

--- Get a mode color from a Heirline* highlight group, falling back to lualine.
local function mode_color(group, mode, fallback)
  local bg = M.get_hlgroup(group, { bg = 'NONE' }).bg
  if bg and bg ~= 'NONE' then
    return bg
  end
  local lualine_col = M.lualine_mode(mode, fallback)
  return to_hex(lualine_col, fallback)
end

--- This function returns a list of colors that can be passed to `heirline.load_colors()`.
function M.get_colors()
  local C = env.fallback_colors

  -- Highlight groups that are actually referenced by components.lua.
  local StatusLine = M.get_hlgroup('StatusLine', { fg = C.fg, bg = C.bg })
  local StatusLineNC = M.get_hlgroup('StatusLineNC', { fg = C.fg, bg = C.bg })
  local TabLineFill = M.get_hlgroup('TabLineFill', { fg = C.fg, bg = C.bg })
  local WinBar = M.get_hlgroup('WinBar', { fg = C.fg, bg = C.bg })
  local WinBarNC = M.get_hlgroup('WinBarNC', { fg = C.fg, bg = C.bg })
  local Conditional = M.get_hlgroup('Conditional', { fg = C.purple, bg = C.bg })
  local TypeDef = M.get_hlgroup('TypeDef', { fg = C.yellow, bg = C.bg })
  local NvimEnvironmentName = M.get_hlgroup('NvimEnvironmentName', { fg = C.yellow, bg = C.bg })

  local GitSignsAdd = M.get_hlgroup('GitSignsAdd', { fg = C.green, bg = C.bg })
  local GitSignsChange = M.get_hlgroup('GitSignsChange', { fg = C.orange, bg = C.bg })
  local GitSignsDelete = M.get_hlgroup('GitSignsDelete', { fg = C.red, bg = C.bg })
  local DiagnosticError = M.get_hlgroup('DiagnosticError', { fg = C.red, bg = C.bg })
  local DiagnosticWarn = M.get_hlgroup('DiagnosticWarn', { fg = C.orange, bg = C.bg })
  local DiagnosticInfo = M.get_hlgroup('DiagnosticInfo', { fg = C.white, bg = C.bg })
  local DiagnosticHint = M.get_hlgroup('DiagnosticHint', { fg = C.yellow, bg = C.bg })

  -- local Normal = get_hlgroup('Normal', { fg = color.fg, bg = color.bg })
  -- local Comment = get_hlgroup('Comment', { fg = color.bright_grey, bg = color.bg })
  -- local Error = get_hlgroup('Error', { fg = color.red, bg = color.bg })
  -- local StatusLine = get_hlgroup('StatusLine', { fg = color.fg, bg = color.dark_bg })
  -- local TabLine = get_hlgroup('TabLine', { fg = color.grey, bg = color.none })
  -- local TabLineFill = get_hlgroup('TabLineFill', { fg = color.fg, bg = color.dark_bg })
  -- local TabLineSel = get_hlgroup('TabLineSel', { fg = color.fg, bg = color.none })
  -- local WinBar = get_hlgroup('WinBar', { fg = color.bright_grey, bg = color.bg })
  -- local WinBarNC = get_hlgroup('WinBarNC', { fg = color.grey, bg = color.bg })
  -- local Conditional = get_hlgroup('Conditional', { fg = color.bright_purple, bg = color.dark_bg })
  -- local String = get_hlgroup('String', { fg = color.green, bg = color.dark_bg })
  -- local TypeDef = get_hlgroup('TypeDef', { fg = color.yellow, bg = color.dark_bg })

  return {
    fg = StatusLine.fg,
    bg = StatusLine.bg,

    inactive_bg = StatusLineNC.bg,
    winbar_fg = WinBar.fg,
    winbar_bg = WinBar.bg,
    wimbar_inactive_bg = WinBarNC.bg,
    tabline_bg = TabLineFill.bg,

    -- Semantic colors
    lsp_active = NvimEnvironmentName.fg,
    macro_recording = NvimEnvironmentName.fg,
    scrollbar = TypeDef.fg,

    -- Git and diagnostics
    git_branch_fg = Conditional.fg,
    git_added = GitSignsAdd.fg,
    git_changed = GitSignsChange.fg,
    git_removed = GitSignsDelete.fg,
    diag_ERROR = DiagnosticError.fg,
    diag_WARN = DiagnosticWarn.fg,
    diag_INFO = DiagnosticInfo.fg,
    diag_HINT = DiagnosticHint.fg,

    -- Modes
    inactive = mode_color('HeirlineInactive', 'inactive', C.gray),
    normal = mode_color('HeirlineNormal', 'normal', C.blue),
    insert = mode_color('HeirlineInsert', 'insert', C.green),
    visual = mode_color('HeirlineVisual', 'visual', C.purple),
    replace = mode_color('HeirlineReplace', 'replace', C.red),
    command = mode_color('HeirlineCommand', 'command', C.yellow),
    terminal = mode_color('HeirlineTerminal', 'insert', C.green),
  }
end

return M
