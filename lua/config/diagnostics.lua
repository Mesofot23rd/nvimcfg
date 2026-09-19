local diagnostic = vim.diagnostic

-- global config for diagnostic
diagnostic.config {

  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚',
      [vim.diagnostic.severity.WARN] = '󰀪',
      [vim.diagnostic.severity.HINT] = '󰌶',
      [vim.diagnostic.severity.INFO] = '',
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

--
-- Toggle diagnostics inline for the current cursor line
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

-- Keymap: press <leader>d to toggle diagnostics for cursor line
vim.keymap.set({ 'n', 'i' }, '<C-d>', toggle_cursor_line_diagnostic, { desc = 'Toggle cursor line diagnostic' })
