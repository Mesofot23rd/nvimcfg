local diagnostic = vim.diagnostic
local icons = require 'custom.icons'

-------------------------------------
----- GLOBAL CONFIG FOR DIAGNOSTIC
-------------------------------------
diagnostic.config {

  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.Warning,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.Information,
    },
  },

  underline = false, -- underline problematic code
  -- virtual_text = {
  --   spacing = 4, -- space between text and code
  --   prefix = '●', -- could be '●', '▎', 'x'
  -- },
  float = { border = 'rounded', style = 'minimal' },
  virtual_lines = false, -- disable virtual lines
  -- signs = true, -- show signs in the gutter
  severity_sort = true, -- sort diagnostics by severity
  update_in_insert = false, -- don't update diagnostics while typing
}

-------------------------------------------------------------------------------
--- @type function : Toggle diagnostics inline for the current cursor line
-------------------------------------------------------------------------------
local function toggle_cursor_line_diagnostic()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- current line (0-indexed)
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })

  if vim.b.cursor_line_diag_open then
    -- Hide by closing floating window
    if vim.b.cursor_line_diag_win and vim.api.nvim_win_is_valid(vim.b.cursor_line_diag_win) then
      vim.api.nvim_win_close(vim.b.cursor_line_diag_win, true)
    end
    vim.b.cursor_line_diag_open = false
    vim.b.cursor_line_diag_win = nil
  else
    if #diagnostics > 0 then
      -- Show diagnostics for current line in a floating window
      vim.b.cursor_line_diag_open = true
      vim.b.cursor_line_diag_win = vim.diagnostic.open_float(bufnr, {
        scope = 'line',
        focusable = false,
        close_events = { 'CursorMoved', 'BufHidden', 'InsertCharPre' },
        border = 'rounded',
      })
    end
  end
end

-- diagnostic
local diagnostic_goto = function(next, severity)
  return function()
    vim.diagnostic.jump {
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    }
  end
end

-------------------------------------
----- DIAGNOSTICS KEYMAPS
-------------------------------------
-- Use <leader>d for line diagnostics float (avoid hijacking <C-d> which is used for half-page scroll)
vim.keymap.set('n', '<M-d>', toggle_cursor_line_diagnostic, { desc = 'Toggle cursor line diagnostic' })
--vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line Diagnostics' })
-- map('n', ']d', diagnostic_goto(true), { desc = 'Next Diagnostic' })
-- map('n', '[d', diagnostic_goto(false), { desc = 'Prev Diagnostic' })
vim.keymap.set('n', ']e', diagnostic_goto(true, 'ERROR'), { desc = 'Next Error' })
vim.keymap.set('n', '[e', diagnostic_goto(false, 'ERROR'), { desc = 'Prev Error' })
vim.keymap.set('n', ']w', diagnostic_goto(true, 'WARN'), { desc = 'Next Warning' })
vim.keymap.set('n', '[w', diagnostic_goto(false, 'WARN'), { desc = 'Prev Warning' })

-- --- quickfix related stuff -----------------------------------------------------
vim.keymap.set('n', '<leader>xq', function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = 'Toggle quickfix' })

--- location list related stuff ------------------------------------------------
vim.keymap.set('n', '<leader>xl', function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = 'Toggle location list' })

--map('n', '<m-j>', '<cmd>cnext<cr>', {desc= 'Next Item in Quicklist'})
--map('n', '<m-k>', '<cmd>cprev<cr>', {desc 'Prev Item in Quicklist'})
--
--
---- Define LSP diagnostics icons defined in ../icons/icons.lua
-- local signs = {
--   { name = 'DiagnosticSignError', text = M.get_icon 'DiagnosticError', texthl = 'DiagnosticSignError' },
--   { name = 'DiagnosticSignWarn', text = M.get_icon 'DiagnosticWarn', texthl = 'DiagnosticSignWarn' },
--   { name = 'DiagnosticSignHint', text = M.get_icon 'DiagnosticHint', texthl = 'DiagnosticSignHint' },
--   { name = 'DiagnosticSignInfo', text = M.get_icon 'DiagnosticInfo', texthl = 'DiagnosticSignInfo' },
--   { name = 'DapStopped', text = M.get_icon 'DapStopped', texthl = 'DiagnosticWarn' },
--   { name = 'DapBreakpoint', text = M.get_icon 'DapBreakpoint', texthl = 'DiagnosticInfo' },
--   { name = 'DapBreakpointRejected', text = M.get_icon 'DapBreakpointRejected', texthl = 'DiagnosticError' },
--   { name = 'DapBreakpointCondition', text = M.get_icon 'DapBreakpointCondition', texthl = 'DiagnosticInfo' },
--   { name = 'DapLogPoint', text = M.get_icon 'DapLogPoint', texthl = 'DiagnosticInfo' },
-- }
-- for _, sign in ipairs(signs) do
--   vim.fn.sign_define(sign.name, sign)
-- end

-- -- Define diagnostic opts
-- local diagnostics_opts = {
--   virtual_text = true,
--   signs = {
--     text = {
--       [vim.diagnostic.severity.ERROR] = M.get_icon 'DiagnosticError',
--       [vim.diagnostic.severity.HINT] = M.get_icon 'DiagnosticHint',
--       [vim.diagnostic.severity.WARN] = M.get_icon 'DiagnosticWarn',
--       [vim.diagnostic.severity.INFO] = M.get_icon 'DiagnosticInfo',
--     },
--     active = signs,
--   },
--   update_in_insert = true,
--   underline = true,
--   severity_sort = true,
--   float = {
--     focused = false,
--     style = 'minimal',
--     border = 'rounded',
--     source = 'always',
--     header = '',
--     prefix = '',
--   },
-- }

-- -- Define the table of options used by vim.g.diagnostics_mode in ../1-options.lua
-- M.diagnostics_enum = {
--   -- diagnostics off
--   [0] = vim.tbl_deep_extend(
--     'force',
--     diagnostics_opts,
--     { underline = false, virtual_text = false, signs = false, update_in_insert = false }
--   ),
--   -- status only
--   vim.tbl_deep_extend('force', diagnostics_opts, { virtual_text = false, signs = false }),
--   -- virtual text off, signs on
--   vim.tbl_deep_extend('force', diagnostics_opts, { virtual_text = false }),
--   -- all diagnostics on
--   diagnostics_opts,
-- }

-- vim.diagnostic.config(M.diagnostics_enum[vim.g.diagnostics_mode])
