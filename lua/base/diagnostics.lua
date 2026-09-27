local diagnostic = vim.diagnostic

-------------------------------------
----- GLOBAL CONFIG FOR DIAGNOSTIC
-------------------------------------
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

-------------------------------------
----- DIAGNOSTICS KEYMAPS
-------------------------------------
vim.keymap.set({ 'n', 'i' }, '<C-d>', toggle_cursor_line_diagnostic, { desc = 'Toggle cursor line diagnostic' })

-- --- quickfix related stuff -----------------------------------------------------
vim.keymap.set('n', '<leader>xq', function()
  local qf = vim.fn.getqflist { winid = 0 }
  if qf.winid ~= 0 then
    vim.cmd 'cclose'
  else
    vim.cmd 'copen | wincmd J'
  end
end, { desc = 'Toggle quickfix' })

--- location list related stuff ------------------------------------------------
vim.keymap.set('n', '<leader>xl', function()
  local loclist = vim.fn.getloclist(0, { winid = 0, size = 0 })
  if loclist.winid ~= 0 then
    vim.cmd 'lclose'
  elseif loclist.size > 0 then
    vim.cmd 'lopen'
  else
    vim.notify('No location list', vim.log.levels.WARN)
  end
end, { desc = 'Toggle location list' })

--map('n', '<m-j>', '<cmd>cnext<cr>', {desc= 'Next Item in Quicklist'})
--map('n', '<m-k>', '<cmd>cprev<cr>', {desc 'Prev Item in Quicklist'})
