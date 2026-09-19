local M = {}
local env = require 'custom.statusline_components.env'

--- Get the highlight background color of the lualine theme for the current colorscheme.
function M.lualine_mode(mode, fallback)
  if not vim.g.colors_name then
    return fallback
  end
  local lualine_avail, lualine = pcall(require, 'lualine.themes.' .. vim.g.colors_name)
  local lualine_opts = lualine_avail and lualine[mode]
  return lualine_opts and type(lualine_opts.a) == 'table' and lualine_opts.a.bg or fallback
end

--- Get the foreground color group for the current mode.
function M.mode_bg()
  local mode = vim.fn.mode()
  return env.modes[mode] and env.modes[mode][2] or 'normal'
end

--- Get highlight properties for a given highlight name.
function M.get_hlgroup(name, fallback)
  if vim.fn.hlexists(name) == 1 then
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    if hl.reverse then
      hl.fg, hl.bg = hl.bg, hl.fg
    end
    local res = {}
    res.fg = hl.fg and string.format('#%06x', hl.fg) or (fallback and fallback.fg or 'NONE')
    res.bg = hl.bg and string.format('#%06x', hl.bg) or (fallback and fallback.bg or 'NONE')
    return res
  end
  return fallback or { fg = 'NONE', bg = 'NONE' }
end

--- This function return a list of colors that can be passed to `heirline.load_colors()`
function M.get_colors()
  local C = env.fallback_colors

  -- Get hlgroups
  local Normal = M.get_hlgroup('Normal', { fg = C.fg, bg = C.bg })
  local Comment = M.get_hlgroup('Comment', { fg = C.bright_grey, bg = C.bg })
  local Error = M.get_hlgroup('Error', { fg = C.red, bg = C.bg })
  local StatusLine = M.get_hlgroup('StatusLine', { fg = C.fg, bg = C.dark_bg })
  local TabLine = M.get_hlgroup('TabLine', { fg = C.grey, bg = C.none })
  local TabLineFill = M.get_hlgroup('TabLineFill', { fg = C.fg, bg = C.dark_bg })
  local TabLineSel = M.get_hlgroup('TabLineSel', { fg = C.fg, bg = C.none })
  local WinBar = M.get_hlgroup('WinBar', { fg = C.bright_grey, bg = C.bg })
  local WinBarNC = M.get_hlgroup('WinBarNC', { fg = C.grey, bg = C.bg })
  local Conditional = M.get_hlgroup('Conditional', { fg = C.bright_purple, bg = C.dark_bg })
  local String = M.get_hlgroup('String', { fg = C.green, bg = C.dark_bg })
  local TypeDef = M.get_hlgroup('TypeDef', { fg = C.yellow, bg = C.dark_bg })
  local NvimEnvironmentName = M.get_hlgroup('NvimEnvironmentName', { fg = C.yellow, bg = C.dark_bg })

  local GitSignsAdd = M.get_hlgroup('GitSignsAdd', { fg = C.green, bg = C.dark_bg })
  local GitSignsChange = M.get_hlgroup('GitSignsChange', { fg = C.orange, bg = C.dark_bg })
  local GitSignsDelete = M.get_hlgroup('GitSignsDelete', { fg = C.bright_red, bg = C.dark_bg })
  local DiagnosticError = M.get_hlgroup('DiagnosticError', { fg = C.bright_red, bg = C.dark_bg })
  local DiagnosticWarn = M.get_hlgroup('DiagnosticWarn', { fg = C.orange, bg = C.dark_bg })
  local DiagnosticInfo = M.get_hlgroup('DiagnosticInfo', { fg = C.white, bg = C.dark_bg })
  local DiagnosticHint = M.get_hlgroup('DiagnosticHint', { fg = C.bright_yellow, bg = C.dark_bg })

  local HeirlineInactive = M.get_hlgroup('HeirlineInactive', { bg = nil }).bg or M.lualine_mode('inactive', C.dark_grey)
  local HeirlineNormal = M.get_hlgroup('HeirlineNormal', { bg = nil }).bg or M.lualine_mode('normal', C.blue)
  local HeirlineInsert = M.get_hlgroup('HeirlineInsert', { bg = nil }).bg or M.lualine_mode('insert', C.green)
  local HeirlineVisual = M.get_hlgroup('HeirlineVisual', { bg = nil }).bg or M.lualine_mode('visual', C.purple)
  local HeirlineReplace = M.get_hlgroup('HeirlineReplace', { bg = nil }).bg or M.lualine_mode('replace', C.bright_red)
  local HeirlineCommand = M.get_hlgroup('HeirlineCommand', { bg = nil }).bg or M.lualine_mode('command', C.bright_yellow)
  local HeirlineTerminal = M.get_hlgroup('HeirlineTerminal', { bg = nil }).bg or M.lualine_mode('insert', HeirlineInsert)

  local colors = {
    close_fg = Error.fg,
    fg = StatusLine.fg,
    bg = StatusLine.bg,

    winbar_fg = WinBar.fg,
    winbar_bg = WinBar.bg,
    winbarnc_fg = WinBarNC.fg,
    winbarnc_bg = WinBarNC.bg,
    tabline_bg = TabLineFill.bg,
    tabline_fg = TabLineFill.bg,

    -- Semantic colors
    lsp_active = NvimEnvironmentName.fg,
    macro_recording = NvimEnvironmentName.fg,

    section_fg = StatusLine.fg,
    section_bg = StatusLine.bg,
    virtual_env_fg = NvimEnvironmentName.fg,
    treesitter_fg = String.fg,
    scrollbar = TypeDef.fg,

    --Git and Diagnostics
    git_branch_fg = Conditional.fg,
    git_added = GitSignsAdd.fg,
    git_changed = GitSignsChange.fg,
    git_removed = GitSignsDelete.fg,
    diag_ERROR = DiagnosticError.fg,
    diag_WARN = DiagnosticWarn.fg,
    diag_INFO = DiagnosticInfo.fg,
    diag_HINT = DiagnosticHint.fg,

    --buffers and Tabs
    buffer_fg = Comment.fg,
    buffer_path_fg = WinBarNC.fg,
    buffer_close_fg = Comment.fg,
    buffer_bg = TabLineFill.bg,
    buffer_active_fg = Normal.fg,
    buffer_active_path_fg = WinBarNC.fg,
    buffer_active_close_fg = Error.fg,
    buffer_active_bg = Normal.bg,
    buffer_visible_fg = Normal.fg,
    buffer_visible_path_fg = WinBarNC.fg,
    buffer_visible_close_fg = Error.fg,
    buffer_visible_bg = Normal.bg,
    buffer_overflow_fg = Comment.fg,
    buffer_overflow_bg = TabLineFill.bg,
    buffer_picker_fg = Error.fg,
    tab_close_fg = Error.fg,
    tab_close_bg = TabLineFill.bg,
    tab_fg = TabLine.fg,
    tab_bg = TabLine.bg,
    tab_active_fg = TabLineSel.fg,
    tab_active_bg = TabLineSel.bg,

    -- Modes
    inactive = HeirlineInactive,
    normal = HeirlineNormal,
    insert = HeirlineInsert,
    visual = HeirlineVisual,
    replace = HeirlineReplace,
    command = HeirlineCommand,
    terminal = HeirlineTerminal,
  }

  return colors
end

return M
