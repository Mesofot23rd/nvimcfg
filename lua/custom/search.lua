local M = {}

M.state = {
  search_term = '',
  replace_term = '',
  case_sensitive = false,
  active = false,
}

---Update the search register and highlights based on current state.
function M.update_search()
  if M.state.search_term == '' then
    return
  end

  local prefix = M.state.case_sensitive and '\\C' or '\\c'
  -- Set search register to trigger native highlighting and navigation
  vim.fn.setreg('/', prefix .. M.state.search_term)
  vim.opt.hlsearch = true
  -- Jump to first match from current position
  pcall(vim.cmd, 'normal! n')
end

function M.toggle_case()
  M.state.case_sensitive = not M.state.case_sensitive
  M.update_search()
  vim.notify('Case Sensitive: ' .. (M.state.case_sensitive and 'ON' or 'OFF'), vim.log.levels.INFO, { title = 'Search&&Replace' })
end

function M.replace_current()
  if M.state.search_term == '' or M.state.replace_term == '' then
    vim.notify('Search or Replace value is empty', vim.log.levels.WARN, { title = 'Search&&Replace' })
    return
  end
  local prefix = M.state.case_sensitive and '\\C' or '\\c'
  -- \%# matches the current cursor position.
  -- This ensures we only replace if the cursor is at the start of the match (standard 'n' behavior).
  local cmd = string.format('s/\\%%#%s%s/%s/', prefix, M.state.search_term, M.state.replace_term)
  local success, _ = pcall(vim.cmd, cmd)
  if success then
    -- Move to next match after replacement
    pcall(vim.cmd, 'normal! n')
  else
    vim.notify('Cursor is not on a match', vim.log.levels.INFO)
  end
end

function M.replace_all()
  if M.state.search_term == '' or M.state.replace_term == '' then
    vim.notify('Search or Replace value is empty', vim.log.levels.WARN, { title = 'Search&&Replace' })
    return
  end
  local prefix = M.state.case_sensitive and '\\C' or '\\c'
  local cmd = string.format('%%s/%s%s/%s/g', prefix, M.state.search_term, M.state.replace_term)
  local success, err = pcall(vim.cmd, cmd)
  if success then
    vim.notify 'Replaced all occurrences'
  else
    vim.notify('Replace all failed: ' .. tostring(err), vim.log.levels.ERROR)
  end
end

function M.replace_mode()
  vim.ui.input({
    prompt = "Replace '" .. M.state.search_term .. "' with: ",
    default = M.state.replace_term,
  }, function(input)
    if input then
      M.state.replace_term = input
      vim.notify('Replace value set to: ' .. input)
    end
  end)
end

---Setup buffer-local keymaps for search and replace mode.
function M.setup_mappings()
  local bufnr = vim.api.nvim_get_current_buf()
  local function opts(desc)
    return { buffer = bufnr, silent = true, desc = 'Search & Replace: ' .. desc }
  end

  -- Navigation:
  vim.keymap.set('n', '<Down>', 'n', opts 'Next match')
  vim.keymap.set('n', '<Up>', 'N', opts 'Previous match')

  -- Toggle Case:
  vim.keymap.set({ 'n', 'i' }, '<C-t>', M.toggle_case, opts 'Toggle Case Sensitivity')

  -- Invoke Replace:
  vim.keymap.set('n', '<C-h>', M.replace_mode, opts 'Set Replace Value')

  -- Replace Current:
  -- Note: <C-CR> might require terminal support; falling back to common sequences if needed
  vim.keymap.set('n', '<CR>', M.replace_current, opts 'Replace Current Match')

  -- Replace All:
  vim.keymap.set('n', '<C-a>', M.replace_current, opts 'Replace All in Buffer')

  -- Quit search and replace:
  vim.keymap.set('n', '<Esc>', function()
    M.stop()
  end, opts 'Exit Search & Replace')
end

---Start the Search & Replace mode.
function M.start()
  vim.ui.input({
    prompt = 'Search: ',
    default = M.state.search_term,
  }, function(input)
    if not input or input == '' then
      return
    end

    M.state.search_term = input
    M.state.active = true
    M.setup_mappings()
    M.update_search()
  end)
end

---Remove buffer-local keymaps and restore state.
function M.clear_mappings()
  local bufnr = vim.api.nvim_get_current_buf()
  local keys = { '<C-Down>', '<C-Up>', '<C-t>', '<C-h>', '<S-CR>', '<C-A-a>', '<Esc>' }
  for _, key in ipairs(keys) do
    pcall(vim.api.nvim_buf_del_keymap, bufnr, 'n', key)
  end
end

---Exit the Search & Replace mode.
function M.stop()
  if not M.state.active then
    return
  end
  M.state.active = false
  vim.opt.hlsearch = false
  M.clear_mappings()
  vim.notify 'Exited Search & Replace mode'
end

return M
