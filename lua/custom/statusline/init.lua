local M = {}
local env = require 'custom.statusline.env'
-- -----------------------------------------------------------------------------
-- Special Buffers to Ignore
-- -----------------------------------------------------------------------------
local ignored_filetypes = {
  ['neo-tree'] = true,
  ['neo-tree-popup'] = true,
  ['NvimTree'] = true,
  ['help'] = true,
  ['qf'] = true,
  ['Trouble'] = true,
  ['lazy'] = true,
  ['mason'] = true,
  ['alpha'] = true,
  ['dashboard'] = true,
  ['starter'] = true,
  ['fzf'] = true,
  ['nvterm'] = true,
  ['terminal'] = true,
}

-- -----------------------------------------------------------------------------
-- Mode Definitions & Colors
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

--local colors = {}

-- -----------------------------------------------------------------------------
-- Highlights Setup
-- -----------------------------------------------------------------------------
function M.setup_highlights()
  -- Statusline Mode Pills
  vim.api.nvim_set_hl(0, 'StatusLineModeNormal', { fg = '#1e1e2e', bg = '#61afef', bold = true })
  vim.api.nvim_set_hl(0, 'StatusLineModeInsert', { fg = '#1e1e2e', bg = '#98c379', bold = true })
  vim.api.nvim_set_hl(0, 'StatusLineModeVisual', { fg = '#1e1e2e', bg = '#c678dd', bold = true })
  vim.api.nvim_set_hl(0, 'StatusLineModeReplace', { fg = '#1e1e2e', bg = '#e06c75', bold = true })
  vim.api.nvim_set_hl(0, 'StatusLineModeCommand', { fg = '#1e1e2e', bg = '#e5c07b', bold = true })
  vim.api.nvim_set_hl(0, 'StatusLineModeTerminal', { fg = '#1e1e2e', bg = '#56b6c2', bold = true })

  -- Git highlights
  vim.api.nvim_set_hl(0, 'StatusLineGit', { fg = '#c678dd', bold = true })
  vim.api.nvim_set_hl(0, 'StatusLineGitAdd', { fg = '#98c379' })
  vim.api.nvim_set_hl(0, 'StatusLineGitChange', { fg = '#e5c07b' })
  vim.api.nvim_set_hl(0, 'StatusLineGitDelete', { fg = '#e06c75' })

  -- Diagnostics
  vim.api.nvim_set_hl(0, 'StatusLineDiagError', { fg = '#e06c75', bold = true })
  vim.api.nvim_set_hl(0, 'StatusLineDiagWarn', { fg = '#e5c07b', bold = true })
  vim.api.nvim_set_hl(0, 'StatusLineDiagInfo', { fg = '#61afef' })
  vim.api.nvim_set_hl(0, 'StatusLineDiagHint', { fg = '#56b6c2' })

  -- Statusline General
  vim.api.nvim_set_hl(0, 'StatusLineNC', { fg = '#5c6370', bg = '#181a1f' })
  vim.api.nvim_set_hl(0, 'StatusLineLsp', { fg = '#98c379' })
  vim.api.nvim_set_hl(0, 'StatusLinePos', { fg = '#828997' })

  -- Winbar
  vim.api.nvim_set_hl(0, 'WinBar', { fg = '#828997', bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'WinBarNC', { fg = '#5c6370', bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'WinBarFile', { fg = '#abb2bf', bold = true })
  vim.api.nvim_set_hl(0, 'WinBarModified', { fg = '#e5c07b', bold = true })
  vim.api.nvim_set_hl(0, 'WinBarReadOnly', { fg = '#e06c75', bold = true })

  -- Tabline
  vim.api.nvim_set_hl(0, 'TabLineSel', { fg = '#1e1e2e', bg = '#61afef', bold = true })
  vim.api.nvim_set_hl(0, 'TabLine', { fg = '#828997', bg = '#282c34' })
  vim.api.nvim_set_hl(0, 'TabLineFill', { bg = '#1e2227' })
  vim.api.nvim_set_hl(0, 'TabLineCwd', { fg = '#61afef', bg = '#282c34' })
end

-- -----------------------------------------------------------------------------
-- Statusline Components
-- -----------------------------------------------------------------------------
function M.component_mode(opts)
  if type(opts) == 'boolean' then
    opts = opts and { uname = true, mode = true } or { uname = true, mode = false }
  else
    opts = opts or {}
  end

  local function getuname()
    local os_uname = (vim.uv or vim.loop).os_uname()

    if vim.fn.has 'mac' == 1 then
      return env.icons.MacOs
    elseif vim.fn.has 'win32' == 1 then
      return env.icons.Windows
    elseif vim.fn.has 'Android' == 1 then
      return env.icons.Android
    elseif os_uname.sysname:match 'Linux' then
      return os_uname.release:lower():find 'arch' and env.icons.Arch or env.icons.Linux
    end

    return ''
  end

  local m = vim.api.nvim_get_mode().mode
  local current = modes[m] or { name = m:upper(), hl = 'StatusLineModeNormal' }

  local parts = {}
  if opts.uname then
    local uname = vim.trim(getuname())
    if uname ~= '' then table.insert(parts, uname) end
  end

  if opts.mode then
    if current.name and current.name ~= '' then table.insert(parts, current.name) end
  end

  if #parts == 0 then return string.format('%%#%s# %%*', current.hl) end

  return string.format('%%#%s# %s %%*', current.hl, table.concat(parts, ' '))
end

--------------------------------------------------------------------------------
function M.component_git()
  local head = vim.b.gitsigns_head
  local dict = vim.b.gitsigns_status_dict
  if not head and not dict then return '' end
  local branch = head or (dict and dict.head) or ''
  if branch == '' then return '' end

  local git_str = string.format(' %%#StatusLineGit# %s%%*', branch)
  if dict then
    if (dict.added or 0) > 0 then git_str = git_str .. string.format(' %%#StatusLineGitAdd# %d%%*', dict.added) end
    if (dict.changed or 0) > 0 then
      git_str = git_str .. string.format(' %%#StatusLineGitChange# %d%%*', dict.changed)
    end
    if (dict.removed or 0) > 0 then
      git_str = git_str .. string.format(' %%#StatusLineGitDelete# %d%%*', dict.removed)
    end
  end
  return git_str
end

--------------------------------------------------------------------------------
function M.component_diagnostics()
  local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local warns = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  local infos = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  local hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })

  local parts = {}
  if errors > 0 then table.insert(parts, string.format('%%#StatusLineDiagError#󰅚 %d%%*', errors)) end
  if warns > 0 then table.insert(parts, string.format('%%#StatusLineDiagWarn# %d%%*', warns)) end
  if infos > 0 then table.insert(parts, string.format('%%#StatusLineDiagInfo# %d%%*', infos)) end
  if hints > 0 then table.insert(parts, string.format('%%#StatusLineDiagHint#󰌶 %d%%*', hints)) end

  if #parts == 0 then return '' end
  return ' ' .. table.concat(parts, ' ')
end

--------------------------------------------------------------------------------
function M.component_lsp()
  local clients = vim.lsp.get_clients { bufnr = 0 }
  if #clients == 0 then return '' end
  local names = {}
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
  end

  return string.format('%%#StatusLineLsp# [%s%%*]', table.concat(names, ', '))
end

--------------------------------------------------------------------------------

M.file = {
  type = function()
    local win = vim.g.statusline_winid or vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) or 0
    local ft = vim.bo[buf].filetype
    if ft ~= '' then return ft end
    local bt = vim.bo[buf].buftype
    return bt ~= '' and bt or ''
  end,

  name = function()
    local win = vim.g.statusline_winid or vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) or 0
    local filename = vim.api.nvim_buf_get_name(buf)
    filename = (filename ~= '') and vim.fn.fnamemodify(filename, ':t') or '[No Name]'
    return ' ' .. filename .. ' '
  end,

  icon = function()
    local win = vim.g.statusline_winid or vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) or 0
    local buftype = vim.bo[buf].buftype
    if buftype == 'terminal' then return ' ' end
    local filename = vim.api.nvim_buf_get_name(buf)
    local extension = vim.fn.fnamemodify(filename, ':e')
    local ok, devicons = pcall(require, 'nvim-web-devicons')
    if ok then
      local ic = devicons.get_icon(filename, extension, { default = true })
      if ic then return ic .. ' ' end
    end
    return ''
  end,

  encoding = function()
    local win = vim.g.statusline_winid or vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) or 0
    local enc = (vim.bo[buf].fenc ~= '' and vim.bo[buf].fenc) or vim.o.enc -- :h 'enc'
    if enc and enc ~= '' and enc:lower() ~= 'utf-8' then return enc:upper() end
    return ''
  end,

  size = function()
    local win = vim.g.statusline_winid or vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) or 0
    local name = vim.api.nvim_buf_get_name(buf)
    if name == '' then return '' end
    local fsize = vim.fn.getfsize(name)
    if fsize <= 0 then return '' end
    local suffix = { 'b', 'k', 'M', 'G', 'T', 'P', 'E' }
    if fsize < 1024 then return fsize .. suffix[1] end
    local i = math.floor((math.log(fsize) / math.log(1024)))
    return string.format('%.2g%s', fsize / math.pow(1024, i), suffix[i + 1] or '')
  end,

  lastmodified = function()
    local win = vim.g.statusline_winid or vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) or 0
    local ftime = vim.fn.getftime(vim.api.nvim_buf_get_name(buf))
    if ftime and ftime > 0 then return os.date('%c', ftime) end
    return ''
  end,
}

setmetatable(M.file, {
  __call = function(_, opts)
    opts = opts or {}
    local parts = {}
    if opts.icon then
      local ic = M.file.icon()
      if ic ~= '' then table.insert(parts, vim.trim(ic)) end
    end
    if opts.name then
      local n = M.file.name()
      if n ~= '' then table.insert(parts, vim.trim(n)) end
    end
    if opts.type then
      local t = M.file.type()
      if t ~= '' then table.insert(parts, t) end
    end
    if opts.encoding then
      local e = M.file.encoding()
      if e ~= '' then table.insert(parts, e) end
    end
    if opts.size then
      local s = M.file.size()
      if s ~= '' then table.insert(parts, s) end
    end
    if opts.lastmodified or opts.last_modified then
      local lm = M.file.lastmodified()
      if lm ~= '' then table.insert(parts, lm) end
    end
    if #parts == 0 then return '' end
    return ' ' .. table.concat(parts, ' ') .. ' '
  end,
})

--------------------------------------------------------------------------------
function M.component_position() return M.position.ruler() .. M.position.percentage() end

function M.component_macro_recording()
  local recording = vim.fn.reg_recording()
  if recording == '' then return '' end
  return string.format('%%#StatusLineDiagWarn# %s %s %%*', env.icons.MacroRecording or '', recording)
end

M.position = {
  ruler = function() return '%#StatusLinePos# %l:%c%*' end,

  percentage = function()
    local win = vim.g.statusline_winid or vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) or 0
    local curr_line = vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_cursor(win)[1] or 1
    local lines = math.max(vim.api.nvim_buf_line_count(buf), 1)

    local p
    if lines <= 1 then
      p = ' All'
    elseif curr_line == 1 then
      p = ' Top'
    elseif curr_line >= lines then
      p = ' Bot'
    else
      p = ' %p%%'
    end
    return string.format('%%#StatusLinePos#%s %%*', p)
  end,

  bar = function()
    local sbar = { '_', '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' }
    local win = vim.g.statusline_winid or vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) or 0
    local curr_line = vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_cursor(win)[1] or 1
    local lines = math.max(vim.api.nvim_buf_line_count(buf), 1)

    local i = math.floor((curr_line - 1) / lines * #sbar) + 1
    i = math.max(1, math.min(#sbar, i))
    return string.format('%%#WinBarModified# %s%%*', string.rep(sbar[i], 1))
  end,
}

setmetatable(M.position, {
  __call = function(_, opts)
    opts = opts or {}
    local parts = {}
    if opts.ruler ~= false then table.insert(parts, M.position.ruler()) end
    if opts.percentage then table.insert(parts, M.position.percentage()) end
    if opts.bar then table.insert(parts, M.position.bar()) end
    return table.concat(parts, '')
  end,
})

-- Component aliases
M.mode = M.component_mode
M.git = M.component_git
M.diagnostics = M.component_diagnostics
M.lsp = M.component_lsp
M.macro_recording = M.component_macro_recording

--------------------------------------------------------------------------------
function _G.custom_statusline()
  local curwin = vim.api.nvim_get_current_win()
  local target_win = vim.g.statusline_winid or curwin
  if not vim.api.nvim_win_is_valid(target_win) then return '' end

  local buf = vim.api.nvim_win_get_buf(target_win)
  if not vim.api.nvim_buf_is_valid(buf) then return '' end

  local ft = vim.bo[buf].filetype
  local bt = vim.bo[buf].buftype
  local is_active = (target_win == curwin)

  -- 1. Statusline for inactive window
  if not is_active then return string.format('%%#StatusLineNC#%s%%=', M.file.name()) end

  -- 2. Statusline for neo-tree
  if ft == 'neo-tree' or ft == 'neo-tree-popup' then
    local mode_comp = is_active and M.component_mode { uname = true } or '%#StatusLineNC# '
    return table.concat {
      mode_comp,
      '%#StatusLineNC#',
      '%=',
      M.file.name(),
      '%=',
      M.position.bar(),
    }
  end

  -- Special buffers to ignore
  if ignored_filetypes[ft] or bt ~= '' then return '%#StatusLineNC#%=' end

  -- Active window scenarios based on window width:
  local width = vim.api.nvim_win_get_width(target_win)

  -- 3. Statusline for active small window (width < 60)
  if width < 60 then
    return table.concat {
      M.component_mode { uname = true },
      '%=',
      M.position.ruler(),
      M.position.percentage(),
      M.position.bar(),
    }
  end

  -- 4. Statusline for active medium window (width < 100)
  if width < 100 then
    local parts = {
      M.component_mode { uname = true },
      M.component_git(),
      M.component_diagnostics(),
      '%=',
    }
    local macro = M.component_macro_recording()
    if macro ~= '' then
      table.insert(parts, macro)
      table.insert(parts, '%=')
    end
    table.insert(parts, M.component_lsp())
    table.insert(parts, M.position.ruler())
    table.insert(parts, M.position.percentage())
    table.insert(parts, M.position.bar())

    -- table.insert(parts, M.component_mode())
    return table.concat(parts)
  end

  -- 5. Statusline for active window (width >= 100)
  local parts = {
    M.component_mode { uname = true, mode = true },
    M.component_git(),
    M.component_diagnostics(),
    '%=',
  }
  local macro = M.component_macro_recording()
  if macro ~= '' then
    table.insert(parts, macro)
    table.insert(parts, '%=')
  end
  table.insert(parts, M.component_lsp())
  table.insert(parts, M.position.ruler())
  table.insert(parts, M.position.percentage())
  table.insert(parts, M.component_mode())
  return table.concat(parts)
end

-- -----------------------------------------------------------------------------
-- Winbar Generator
-- -----------------------------------------------------------------------------
function _G.custom_winbar()
  local curwin = vim.api.nvim_get_current_win()
  local target_win = vim.g.statusline_winid or curwin
  if not vim.api.nvim_win_is_valid(target_win) then return '' end

  local buf = vim.api.nvim_win_get_buf(target_win)
  if not vim.api.nvim_buf_is_valid(buf) then return '' end

  local bt = vim.bo[buf].buftype
  local ft = vim.bo[buf].filetype

  -- Skip floating windows, neo-tree, and special buftypes
  if bt ~= '' or ignored_filetypes[ft] then return '' end

  local is_active = (target_win == curwin)
  local name = vim.api.nvim_buf_get_name(buf)
  local path = (name ~= '') and vim.fn.fnamemodify(name, ':~:.') or '[No Name]'

  local hl_file = is_active and '%#WinBarFile#' or '%#WinBarNC#'
  local mod = vim.bo[buf].modified and ' %#WinBarModified#%*' or ''
  local ro = (vim.bo[buf].readonly or not vim.bo[buf].modifiable) and ' %#WinBarReadOnly#%*' or ''

  return string.format('  %s %s%%*%s%s', hl_file, path, mod, ro)
end

-- -----------------------------------------------------------------------------
-- Tabline Generator
-- -----------------------------------------------------------------------------
function _G.custom_tabline()
  local tabs = {}
  local current_tab = vim.api.nvim_get_current_tabpage()

  for idx, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local is_selected = (tab == current_tab)
    local hl = is_selected and '%#TabLineSel#' or '%#TabLine#'

    local win = vim.api.nvim_tabpage_get_win(tab)
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    name = (name ~= '') and vim.fn.fnamemodify(name, ':t') or '[No Name]'

    local mod = vim.bo[buf].modified and ' +' or ''
    table.insert(tabs, string.format('%s%%%dT  %d: %s%s %%T%%*', hl, idx, idx, name, mod))
  end

  local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
  local right = string.format('%%#TabLineCwd#  %s  %%*', cwd)

  return table.concat(tabs, '') .. '%#TabLineFill#%=' .. right
end

-- -----------------------------------------------------------------------------
-- Statuscolumn Generator
-- -----------------------------------------------------------------------------
function _G.custom_statuscolumn()
  local win = vim.g.statusline_winid or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then return '' end
  local buf = vim.api.nvim_win_get_buf(win)
  if not vim.api.nvim_buf_is_valid(buf) then return '' end

  local buftype = vim.bo[buf].buftype
  local filetype = vim.bo[buf].filetype

  -- Disable statuscolumn in special buffers and neo-tree
  if buftype ~= '' or ignored_filetypes[filetype] then return '' end

  -- On wrapped lines or virtual text, don't show duplicate line numbers
  if vim.v.virtnum ~= 0 then return '%s%= ' end

  local lnum = vim.v.lnum
  local relnum = vim.v.relnum

  -- Only show a relative number when 'relativenumber' is on and the line is not
  -- the cursor line; otherwise show the absolute line number.
  local num = lnum
  if vim.wo[win].relativenumber and relnum > 0 then num = relnum end

  return string.format('%%C%l%s%%=%2d ', num)
end

-- -----------------------------------------------------------------------------
-- Setup Function
-- -----------------------------------------------------------------------------
function M.setup()
  M.setup_highlights()

  -- Register highlights refresh on color scheme changes
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('CustomUIHighlights', { clear = true }),
    callback = function() M.setup_highlights() end,
  })

  -- Automatically strip statuscolumn & numbers from special buffers
  vim.api.nvim_create_autocmd({ 'FileType', 'BufWinEnter' }, {
    group = vim.api.nvim_create_augroup('CustomSpecialBufferColumn', { clear = true }),
    callback = function(args)
      local buf = args.buf or vim.api.nvim_get_current_buf()
      local ft = vim.bo[buf].filetype
      local bt = vim.bo[buf].buftype

      if bt ~= '' or ignored_filetypes[ft] then
        vim.wo.statuscolumn = ''
        vim.wo.number = false
        vim.wo.relativenumber = false
        vim.wo.signcolumn = 'no'
      end
    end,
  })

  -- Keep the config's session options: old session files can restore a broader
  -- 'sessionoptions' (with "options"/"globals"), which would persist the wrong
  -- laststatus again on the next save.
  local session_options = vim.o.sessionoptions

  -- Window-local UI options, set explicitly per window because 'statuscolumn'
  -- has no global default to inherit from.
  local win_ui_options = {
    statusline = '%!v:lua.custom_statusline()',
    winbar = '%!v:lua.custom_winbar()',
    --statuscolumn = '%!v:lua.custom_statuscolumn()',
  }

  -- All UI options live here so they can be re-applied after a session restore.
  local function apply_ui_options()
    -- Statusline (laststatus=2 enables per-window statusline; inactive windows render empty)
    vim.o.laststatus = 2

    -- Tabline (always visible)
    vim.opt.showtabline = 2
    vim.o.tabline = '%!v:lua.custom_tabline()'

    for name, value in pairs(win_ui_options) do
      vim.o[name] = value
    end
  end

  apply_ui_options()

  -- Sessions are sourced *after* the config is loaded, and a session saved with
  -- 'sessionoptions' containing "options"/"localoptions" can restore UI options
  -- from an older config. Most notably `set laststatus=3`, which turns the
  -- statusline into one global bar spanning the whole editor instead of one per
  -- window. Re-assert our options after every restore.
  vim.api.nvim_create_autocmd('SessionLoadPost', {
    group = vim.api.nvim_create_augroup('CustomUISessionRestore', { clear = true }),
    callback = function()
      apply_ui_options()
      vim.o.sessionoptions = session_options

      -- Overwrite stale window-local copies restored from previous statusline
      -- plugins (heirline, lualine, ...). "localoptions" sessions also restore
      -- per-window 'number'/'relativenumber' from older configs, so re-apply the
      -- config defaults here too.
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local special = vim.bo[buf].buftype ~= '' or ignored_filetypes[vim.bo[buf].filetype]

        if special then
          vim.wo[win].statuscolumn = ''
          vim.wo[win].number = false
          vim.wo[win].relativenumber = false
        else
          vim.wo[win].number = true
          vim.wo[win].relativenumber = false

          for name, value in pairs(win_ui_options) do
            vim.wo[win][name] = value
          end
        end
      end
    end,
  })
end

-- Automatically execute setup when loaded
M.setup()

return M
