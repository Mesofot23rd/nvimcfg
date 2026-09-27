M = {}

local config_dir = vim.fn.stdpath 'config'
local remote_url = 'https://github.com/Mesofot23rd/nvimcfg.git'

---------------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------------

--- Run a git command in the config directory.
--- @param args table Git arguments (e.g. { 'fetch', 'origin' })
--- @return string|nil output The command output, or nil on failure.
local function git(args)
  local cmd = vim.list_extend({ 'git', '-C', config_dir }, args)
  local output = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify(
      'git ' .. table.concat(args, ' ') .. ' failed:\n' .. output,
      vim.log.levels.ERROR,
      { title = 'Config Update' }
    )
    return nil
  end
  return output
end

--- Get the current local commit hash.
--- @return string|nil
local function local_commit()
  return git({ 'rev-parse', 'HEAD' })
end

--- Get the number of commits behind the remote.
--- @return number
local function commits_behind()
  local output = git({ 'rev-list', '--count', 'HEAD..@{u}' })
  if not output then return 0 end
  return tonumber(output:match '%d+') or 0
end

--- Get the number of commits ahead of the remote.
--- @return number
local function commits_ahead()
  local output = git({ 'rev-list', '--count', '@{u}..HEAD' })
  if not output then return 0 end
  return tonumber(output:match '%d+') or 0
end

--- Get the current branch name.
--- @return string|nil
local function current_branch()
  return git({ 'rev-parse', '--abbrev-ref', 'HEAD' })
end

--- Get a short log of commits that would be pulled.
--- @param count number Number of commits to show.
--- @return table<string> List of commit log lines (oldest first).
local function incoming_log(count)
  local output = git({ 'log', '--oneline', '--no-decorate', 'HEAD..@{u}' })
  if not output then return {} end
  local lines = vim.split(output, '\n', { trimempty = true })
  -- git log shows newest first; reverse so oldest is first (chronological order)
  local reversed = {}
  for i = #lines, 1, -1 do
    table.insert(reversed, lines[i])
  end
  return reversed
end

--- Get the short hash of a commit.
--- @param commit string Full or short hash.
--- @return string Short hash (7 chars).
local function short_hash(commit)
  return commit and commit:sub(1, 7) or '?'
end

---------------------------------------------------------------------------------
-- Floating Window UI (Lazy.nvim style)
---------------------------------------------------------------------------------

local buf_id = nil
local win_id = nil

--- Close the floating window if open.
local function close_window()
  if win_id and vim.api.nvim_win_is_valid(win_id) then
    vim.api.nvim_win_close(win_id, true)
  end
  win_id = nil
  buf_id = nil
end

--- Render lines into the floating window buffer.
--- @param lines table<string> Lines to display.
local function render(lines)
  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then return end
  vim.api.nvim_buf_set_option(buf_id, 'modifiable', true)
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf_id, 'modifiable', false)
end

--- Show the floating window with content.
--- @param lines table<string> Lines to display.
local function show_window(lines)
  close_window()

  buf_id = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf_id, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf_id, 'filetype', 'config-update')

  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(#lines + 2, vim.o.lines - 4)

  win_id = vim.api.nvim_open_win(buf_id, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' Config Update ',
    title_pos = 'center',
  })

  vim.api.nvim_win_set_option(win_id, 'wrap', true)
  vim.api.nvim_win_set_option(win_id, 'number', false)
  vim.api.nvim_win_set_option(win_id, 'relativenumber', false)
  vim.api.nvim_win_set_option(win_id, 'signcolumn', 'no')
  vim.api.nvim_win_set_option(win_id, 'cursorline', true)

  render(lines)

  -- Keymaps for the floating window
  local opts = { buffer = buf_id, nowait = true }
  vim.keymap.set('n', 'q', close_window, opts)
  vim.keymap.set('n', '<Esc>', close_window, opts)
  vim.keymap.set('n', 'u', function()
    close_window()
    M.update()
  end, opts)
  vim.keymap.set('n', 'c', function()
    close_window()
    M.check()
  end, opts)
end

---------------------------------------------------------------------------------
-- Check for updates
---------------------------------------------------------------------------------

--- Check if the config is behind the remote.
--- Fetches from origin and compares local vs remote commits.
--- Shows a floating window with the result (Lazy.nvim style).
function M.check()
  vim.notify('Checking for config updates...', vim.log.levels.INFO, { title = 'Config Update' })

  -- Fetch latest refs from remote without merging
  git({ 'fetch', 'origin' })

  local behind = commits_behind()
  local ahead = commits_ahead()
  local branch = current_branch() or 'unknown'
  local local_hash = short_hash(local_commit())

  if behind == 0 then
    local lines = {
      '',
      ('  Config is up to date!'),
      '',
      ('  Branch: %s'):format(branch),
      ('  Commit: %s'):format(local_hash),
      '',
      '  Press q to close',
    }
    show_window(lines)
    return false
  end

  local log = incoming_log(behind)
  local commit_word = behind == 1 and 'commit' or 'commits'

  local lines = {
    '',
    ('  Config is %d %s behind!'):format(behind, commit_word),
    '',
    ('  Branch: %s'):format(branch),
    ('  Commit: %s'):format(local_hash),
    '',
    '  Incoming changes:',
  }
  for _, line in ipairs(log) do
    table.insert(lines, '    ' .. line)
  end
  table.insert(lines, '')
  table.insert(lines, '  Press u to update | q to close')

  show_window(lines)
  return true
end

---------------------------------------------------------------------------------
-- Pull updates
---------------------------------------------------------------------------------

--- Pull the latest config changes from the remote.
--- Shows a summary in a floating window (Lazy.nvim style).
function M.update()
  vim.notify('Pulling config updates...', vim.log.levels.INFO, { title = 'Config Update' })

  local before = local_commit()
  local behind = commits_behind()
  local log = incoming_log(behind)

  local output = git({ 'pull', '--ff-only', 'origin' })
  if not output then
    show_window({
      '',
      '  Failed to pull updates!',
      '',
      '  Check the error message above.',
      '',
      '  Press q to close',
    })
    return
  end

  local after = local_commit()

  if before == after then
    show_window({
      '',
      '  Config is already up to date.',
      '',
      '  Press q to close',
    })
    return
  end

  local commit_word = behind == 1 and 'commit' or 'commits'
  local lines = {
    '',
    ('  Config updated! (%d %s pulled)'):format(behind, commit_word),
    '',
    ('  %s..%s'):format(short_hash(before), short_hash(after)),
    '',
    '  Changes:',
  }
  for _, line in ipairs(log) do
    table.insert(lines, '    ' .. line)
  end
  table.insert(lines, '')
  table.insert(lines, '  Please restart Neovim to apply changes.')
  table.insert(lines, '')
  table.insert(lines, '  Press q to close')

  show_window(lines)
end

---------------------------------------------------------------------------------
-- Status
---------------------------------------------------------------------------------

--- Show the current config git status in a floating window.
function M.status()
  local branch = current_branch() or 'unknown'
  local behind = commits_behind()
  local ahead = commits_ahead()
  local local_hash = short_hash(local_commit())

  local lines = {
    '',
    '  Config Git Status',
    '',
    ('  Branch: %s'):format(branch),
    ('  Commit: %s'):format(local_hash),
    ('  Remote: %s'):format(remote_url),
    ('  Status: %d ahead, %d behind'):format(ahead, behind),
    '',
    '  Press q to close',
  }

  show_window(lines)
end

---------------------------------------------------------------------------------
-- Auto-check on startup (like Lazy.nvim checker)
---------------------------------------------------------------------------------

--- Automatically check for updates on startup.
--- Runs silently; only notifies if updates are available.
function M.autocheck()
  vim.defer_fn(function()
    git({ 'fetch', 'origin' })
    local behind = commits_behind()
    if behind > 0 then
      local commit_word = behind == 1 and 'commit' or 'commits'
      vim.notify(
        ('Config is %d %s behind. Run :ConfigUpdateCheck to review.'):format(behind, commit_word),
        vim.log.levels.WARN,
        { title = 'Config Update' }
      )
    end
  end, 3000) -- 3s delay to not interfere with startup
end

---------------------------------------------------------------------------------
-- User Commands
---------------------------------------------------------------------------------

vim.api.nvim_create_user_command('ConfigUpdateCheck', function()
  M.check()
end, { desc = 'Check for config updates from remote' })

vim.api.nvim_create_user_command('ConfigUpdate', function()
  M.update()
end, { desc = 'Pull latest config updates from remote' })

vim.api.nvim_create_user_command('ConfigUpdateStatus', function()
  M.status()
end, { desc = 'Show config git status' })

return M
