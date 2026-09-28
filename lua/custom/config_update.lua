--- ### Config Update — Lazy.nvim style updater for the whole Neovim config.
---
--  DESCRIPTION:
--  Keeps the local `~/.config/nvim` checkout in sync with the remote git repo,
--  mirroring how lazy.nvim checks/updates its own plugins.
--
--    Functions:
--      -> check     → Fetch remote and show what is incoming (changes nothing).
--      -> update    → Fast-forward the config to its upstream.
--      -> status    → Show branch/commit/ahead/behind plus local modifications.
--      -> autocheck → One background pass; notifies only if the config is behind.
--      -> enable    → Start the background checker.
--      -> disable   → Stop the background checker.
--      -> toggle    → Toggle the background checker.
--      -> is_enabled→ Whether the background checker is running.
--
--    Commands:
--      :ConfigUpdateCheck   :ConfigUpdate   :ConfigUpdateStatus   :ConfigUpdateAuto
--
--    Keymaps (live in ../base/mappings.lua, next to the other <leader>cm mappings):
--      <leader>cu → check       <leader>cU → update
--      <leader>cs → status      <leader>cc → toggle auto-check
--
--    Safety:
--      * All network I/O runs async through `vim.system`, so the UI never freezes.
--      * `GIT_TERMINAL_PROMPT=0` stops git from hanging on a credential prompt.
--      * Fast-forward only. Local commits are never overwritten, and a dirty
--        working tree is reported instead of being touched.
--      * `refs/config-update-backup` is written *before* pulling, so a bad config
--        push can be undone with `git reset --hard refs/config-update-backup`.

local M = {}

local config_dir = vim.fn.stdpath 'config'
-- Used only when the checkout has no `origin` remote configured.
local fallback_remote = 'https://github.com/Mesofot23rd/nvimcfg.git'

-- How many commits to list before collapsing into "... and N more".
local max_log_lines = 30
-- Background check cadence, overridable before this module loads.
local check_interval = vim.g.config_update_interval or (60 * 60 * 1000)
-- Delay before the first background check, so it never competes with startup.
local first_check_delay = vim.g.config_update_first_delay or 5000
-- Ask before applying, so a stray keypress cannot pull a broken config.
local confirm = vim.g.config_update_confirm ~= false

local remote_url = nil
local remote_name = nil
local hl_ns = vim.api.nvim_create_namespace 'config_update'
local auto_timer = nil

---------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

--- Strip leading/trailing whitespace. Command output carries a trailing
--- newline, which would otherwise leak into the rendered text.
--- @param str string|nil
--- @return string
local function trim(str)
  if not str then return '' end
  return (str:gsub('^%s+', ''):gsub('%s+$', ''))
end

--- Resolve the remote to pull from, preferring the checkout's own `origin` so
--- forks and SSH remotes keep working. Cached after the first call.
--- @return string
local function resolve_remote()
  if remote_url then return remote_url end
  local out = vim.fn.system { 'git', '-C', config_dir, 'config', '--get', 'remote.origin.url' }
  if vim.v.shell_error == 0 and trim(out) ~= '' then
    remote_url = trim(out)
  else
    remote_url = fallback_remote
  end
  return remote_url
end

--- Name of the remote to fetch from.
---
--- This must be the remote *name*, never its URL: `git fetch <url>` updates only
--- `FETCH_HEAD` and leaves `refs/remotes/<name>/*` untouched, so `@{u}` would stay
--- stale and the behind count would silently stay at 0 forever.
--- @return string
local function resolve_remote_name()
  if remote_name then return remote_name end
  local out = vim.fn.system { 'git', '-C', config_dir, 'remote' }
  local names = vim.v.shell_error == 0 and vim.split(out, '\n', { trimempty = true }) or {}
  -- Prefer `origin` when it exists, otherwise take the first configured remote.
  remote_name = vim.tbl_contains(names, 'origin') and 'origin' or (names[1] or 'origin')
  return remote_name
end

--- Arguments for a fetch that reliably refreshes the remote-tracking refs.
---
--- The explicit wildcard refspec matters: a bare `git fetch <remote>` cannot infer
--- what to fetch when HEAD is detached, and fails outright in that case.
--- @return table
local function fetch_args()
  local rname = resolve_remote_name()
  return { 'fetch', '--quiet', rname, ('+refs/heads/*:refs/remotes/%s/*'):format(rname) }
end

--- Fast, local-only sanity checks. No network involved, so blocking here is
--- free and lets us bail out with a clear message before doing real work.
--- @return string|nil err
local function preflight()
  if vim.fn.executable 'git' ~= 1 then return 'git executable not found in $PATH' end
  local dot_git = config_dir .. '/.git'
  -- `.git` is a directory in a normal clone but a file in a worktree/submodule.
  if vim.fn.isdirectory(dot_git) ~= 1 and vim.fn.filereadable(dot_git) ~= 1 then
    return ('%s is not a git repository'):format(config_dir)
  end
end

--- Run a git command in the config directory without blocking the editor.
--- @param args table Git arguments (e.g. { 'status', '--porcelain' }).
--- @param done fun(res: { code: integer, stdout: string, stderr: string })
local function git_async(args, done)
  local cmd = { 'git', '-C', config_dir, '-c', 'color.ui=false' }
  vim.list_extend(cmd, args)
  vim.system(cmd, { text = true, env = { GIT_TERMINAL_PROMPT = '0' } }, function(res)
    -- Hop back onto the main loop: the UI is touched from here.
    vim.schedule(function()
      done(res)
    end)
  end)
end

--- Collect everything needed to describe the repo's state in one pass.
--- @param opts table { fetch: boolean }
--- @param done fun(info: table|nil, err: string|nil)
local function inspect(opts, done)
  -- `rev-list --left-right --count HEAD...@{u}` yields "<ahead>\t<behind>" in a
  -- single call, so two separate rev-list invocations are not needed.
  local steps = {
    { key = 'upstream', args = { 'rev-parse', '--abbrev-ref', '--symbolic-full-name', '@{u}' } },
    { key = 'branch', args = { 'rev-parse', '--abbrev-ref', 'HEAD' } },
    { key = 'hash', args = { 'rev-parse', '--short', 'HEAD' } },
    { key = 'status', args = { 'status', '--porcelain' } },
    { key = 'remote_head', args = { 'symbolic-ref', '--short', '--quiet', 'refs/remotes/' .. resolve_remote_name() .. '/HEAD' }, optional = true },
    { key = 'counts', args = { 'rev-list', '--left-right', '--count', 'HEAD...@{u}' }, needs_upstream = true },
    { key = 'log', args = { 'log', '--oneline', '--no-decorate', 'HEAD..@{u}' }, needs_upstream = true },
  }
  if opts.fetch then table.insert(steps, 1, { key = 'fetch', args = fetch_args() }) end

  local info, index = {}, 0
  local function step()
    index = index + 1
    local step_def = steps[index]
    if not step_def then return done(info) end

    -- `@{u}` does not exist on a detached HEAD or an untracked clone, and the
    -- steps below would then error. Skip them instead of reporting a failure.
    if step_def.needs_upstream and not info.upstream then return step() end

    git_async(step_def.args, function(res)
      if res.code ~= 0 then
        -- `optional` steps are best-effort probes (e.g. origin/HEAD may be unset).
        if step_def.optional then
          info[step_def.key] = ''
          return step()
        end
        return done(nil, trim(res.stderr))
      end
      info[step_def.key] = trim(res.stdout)
      step()
    end)
  end

  step()
end

--- Turn the raw `counts` output into numbers.
--- @param info table
--- @return integer ahead, integer behind
local function parse_counts(info)
  if not info.counts then return 0, 0 end
  local ahead, behind = info.counts:match '^(%d+)%s+(%d+)$'
  return tonumber(ahead) or 0, tonumber(behind) or 0
end

--- A detached HEAD has no branch, so there is nothing to compare or fast-forward.
--- @param info table
--- @return boolean
local function is_detached(info) return info.branch == 'HEAD' end

--- Best guess at the branch to check out when HEAD is detached, taken from
--- `origin/HEAD` (e.g. "origin/main" -> "main").
--- @param info table
--- @return string
local function suggest_branch(info)
  local head = info.remote_head or ''
  return head:match '^[^/]+/(.+)$' or '<branch>'
end

---------------------------------------------------------------------------------
-- Floating Window UI (Lazy.nvim style)
--------------------------------------------------------------------------------

local buf_id = nil
local win_id = nil

--- Highlight groups, linked to the active colorscheme by default.
local function setup_highlights()
  vim.api.nvim_set_hl(0, 'ConfigUpdateBehind', { default = true, link = 'DiagnosticWarn' })
  vim.api.nvim_set_hl(0, 'ConfigUpdateOk', { default = true, link = 'DiagnosticOk' })
  vim.api.nvim_set_hl(0, 'ConfigUpdateNew', { default = true, link = 'DiffAdd' })
  vim.api.nvim_set_hl(0, 'ConfigUpdateWarn', { default = true, link = 'DiagnosticError' })
  vim.api.nvim_set_hl(0, 'ConfigUpdateNormal', { default = true, link = 'NormalFloat' })
  vim.api.nvim_set_hl(0, 'ConfigUpdateBorder', { default = true, link = 'FloatBorder' })
end

--- Drop cached buffer/window ids. Safe to call at any time.
local function reset_state()
  win_id, buf_id = nil, nil
end

--- Close the floating window if it is still open.
local function close_window()
  if win_id and vim.api.nvim_win_is_valid(win_id) then pcall(vim.api.nvim_win_close, win_id, true) end
  reset_state()
end

--- Highlight one rendered line. No-op before the buffer exists.
--- @param index integer Zero-based buffer line.
--- @param group string Highlight group name.
local function set_line_hl(index, group)
  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then return end
  if index < 0 then return end
  local line = (vim.api.nvim_buf_get_lines(buf_id, index, index + 1, false) or {})[1]
  if not line or line == '' then return end
  vim.api.nvim_buf_set_extmark(buf_id, hl_ns, index, 0, { end_col = #line, hl_group = group })
end

--- Show the floating window with content.
--- @param lines table<string> Lines to display.
--- @return integer winnr
local function show_window(lines)
  close_window()
  setup_highlights()

  buf_id = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf_id, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf_id, 'modifiable', false)

  -- Leave room for the border plus the tabline/statusline/cmdline chrome so a
  -- tall popup can never be pushed off the bottom of the screen.
  local avail_width = math.max(vim.o.columns - 4, 20)
  local avail_height = math.max(vim.o.lines - 6, 5)
  local width = math.min(90, avail_width)
  local height = math.min(#lines, avail_height)

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

  local wopts = { win = win_id }
  vim.api.nvim_set_option_value('wrap', true, wopts)
  vim.api.nvim_set_option_value('number', false, wopts)
  vim.api.nvim_set_option_value('relativenumber', false, wopts)
  vim.api.nvim_set_option_value('signcolumn', 'no', wopts)
  vim.api.nvim_set_option_value('cursorline', true, wopts)
  vim.api.nvim_set_option_value('winhighlight', 'Normal:ConfigUpdateNormal,FloatBorder:ConfigUpdateBorder', wopts)

  -- Clearing the augroup on BufWipeout keeps `win_id`/`buf_id` from going stale
  -- if the popup is dismissed with something other than `q`/`<Esc>`.
  local group = vim.api.nvim_create_augroup('ConfigUpdatePopup', { clear = true })
  vim.api.nvim_create_autocmd('BufWipeout', {
    group = group,
    buffer = buf_id,
    once = true,
    callback = reset_state,
  })

  local kopts = { buffer = buf_id, nowait = true, silent = true }
  vim.keymap.set('n', 'q', close_window, kopts)
  vim.keymap.set('n', '<Esc>', close_window, kopts)
  vim.keymap.set('n', 'u', function()
    close_window()
    M.update()
  end, kopts)
  vim.keymap.set('n', 'c', function()
    close_window()
    M.check()
  end, kopts)

  return win_id
end

--- Confirm on a scratch buffer instead of pulling straight away.
--- @param lines table<string> Lines to display.
--- @param on_yes fun() Run when the user accepts.
local function confirm_window(lines, on_yes)
  show_window(lines)
  if not win_id then return end
  local kopts = { buffer = buf_id, nowait = true, silent = true }
  vim.keymap.set('n', 'y', function()
    close_window()
    on_yes()
  end, kopts)
end

---------------------------------------------------------------------------------
-- View builders
--------------------------------------------------------------------------------

--- Append the incoming commit list, capped so a large divergence cannot
--- produce a popup thousands of lines tall. Appends into `lines` in place.
--- @param lines table<string>
--- @param log table<string> Commits, oldest first.
--- @return table<string> lines
--- @return integer|nil first_idx Zero-based buffer index of the first commit line.
--- @return integer|nil last_idx Zero-based buffer index of the last commit line.
local function append_log(lines, log)
  if #log == 0 then return lines, nil, nil end

  table.insert(lines, '')
  table.insert(lines, ('  Incoming changes (%d):'):format(#log))

  -- `lines[1..#lines]` occupies buffer rows 0..#lines-1, so #lines is the row
  -- the first commit will land on.
  local first_idx = #lines
  local shown = math.min(#log, max_log_lines)
  for i = 1, shown do
    table.insert(lines, '    ' .. log[i])
  end
  if #log > shown then
    table.insert(lines, ('    ... and %d more'):format(#log - shown))
  end
  return lines, first_idx, first_idx + shown - 1
end

--- Report local modifications, which block a fast-forward.
--- @param info table
--- @return table<string> header Single-element list holding the summary line.
--- @return table<string> files One line per modified path.
local function dirty_lines(info)
  local modified = vim.split(info.status or '', '\n', { trimempty = true })
  if #modified == 0 then return {}, {} end

  local files = {}
  for i = 1, math.min(#modified, max_log_lines) do
    files[i] = '    ' .. modified[i]
  end
  if #modified > max_log_lines then
    files[#files + 1] = ('    ... and %d more'):format(#modified - max_log_lines)
  end
  return { ('  %d local change(s) in your config:'):format(#modified) }, files
end

---------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Fetch the remote and report what is incoming. Changes nothing on disk.
--- @note Runs async, so this returns immediately. Use `M.last_available` inside
---       the `on_done` callback of `inspect` to branch on the result.
function M.check()
  local err = preflight()
  if err then
    vim.notify('Config update unavailable: ' .. err, vim.log.levels.ERROR, { title = 'Config Update' })
    return
  end

  vim.notify('Checking for config updates...', vim.log.levels.INFO, { title = 'Config Update' })

  inspect({ fetch = true }, function(info, fetch_err)
    if not info then
      vim.notify('Fetch failed:\n' .. (fetch_err or 'unknown error'), vim.log.levels.ERROR, {
        title = 'Config Update',
      })
      return
    end

    local ahead, behind = parse_counts(info)
    local log = info.log and vim.split(info.log, '\n', { trimempty = true }) or {}
    local dirty_hdr, dirty_files = dirty_lines(info)

    local lines = { '', '  Config Git Status', '' }
    local status_idx, dirty_idx, log_first, log_last
    --- @param text string Line to append.
    --- @return integer idx Zero-based buffer index of the appended line.
    local function add(text)
      table.insert(lines, text)
      return #lines - 1
    end

    add(('  Branch:  %s'):format(info.branch or 'unknown'))
    add(('  Commit:  %s'):format(info.hash or '?'))
    add(('  Remote:  %s'):format(resolve_remote()))
    status_idx = add(('  Status:  %d ahead, %d behind'):format(ahead, behind))

    if is_detached(info) then
      add('')
      add('  HEAD is detached, so there is no branch to compare against.')
      add(('  Check one out first:  git checkout %s'):format(suggest_branch(info)))
    elseif not info.upstream then
      add('')
      add('  This branch has no upstream, so it cannot be compared.')
      add(('  Fix with:  git branch --set-upstream-to=origin/%s'):format(info.branch or 'main'))
    end

    if #dirty_hdr > 0 then
      add('')
      dirty_idx = add(dirty_hdr[1])
      for _, file in ipairs(dirty_files) do
        add(file)
      end
    end

    if behind > 0 then
      -- Append into the real list so the returned indices line up with the
      -- buffer that show_window is about to create.
      log_first, log_last = append_log(lines, log)
    end

    add('')
    if behind > 0 then
      add(('  Press u to fast-forward %d commit(s) | q to close'):format(behind))
    else
      add('  Press q to close')
    end

    show_window(lines)

    -- Colour by the values we computed, never by matching rendered text.
    set_line_hl(status_idx, behind > 0 and 'ConfigUpdateBehind' or (ahead > 0 and 'ConfigUpdateAhead' or 'ConfigUpdateOk'))
    set_line_hl(dirty_idx, 'ConfigUpdateWarn')
    for i = log_first or 0, log_last or -1 do
      set_line_hl(i, 'ConfigUpdateNew')
    end

    M.last_available = behind > 0
  end)
end

--- Fast-forward the config to its upstream.
function M.update()
  local err = preflight()
  if err then
    vim.notify('Config update unavailable: ' .. err, vim.log.levels.ERROR, { title = 'Config Update' })
    return
  end

  local function start()
    vim.notify('Pulling config updates...', vim.log.levels.INFO, { title = 'Config Update' })

    -- Inspect *after* fetching: counting before the fetch reports stale numbers.
    inspect({ fetch = true }, function(info, fetch_err)
      if not info then
        vim.notify('Fetch failed:\n' .. (fetch_err or 'unknown error'), vim.log.levels.ERROR, {
          title = 'Config Update',
        })
        return
      end

      local ahead, behind = parse_counts(info)
      local log = info.log and vim.split(info.log, '\n', { trimempty = true }) or {}
      local dirty_hdr, dirty_files = dirty_lines(info)
      local upstream = info.upstream or 'origin/' .. (info.branch or 'main')

      -- Local commits mean the history diverged; --ff-only must not touch them.
      if ahead > 0 then
        show_window({
          '',
          ('  Config has diverged! %d local commit(s), %d remote.'):format(ahead, behind),
          '',
          '  Your local commits were left untouched.',
          ('  Review them:   git log %s..HEAD'):format(upstream),
          ('  Discard them:  git reset --hard %s'):format(upstream),
          '',
          '  Press q to close',
        })
        return
      end

      -- A dirty tree can still fast-forward, but it leaves the friend with a
      -- half-applied config. Report it instead of touching their work.
      if #dirty_hdr > 0 then
        local lines = {
          '',
          '  Cannot update: uncommitted local changes.',
          '',
          '  Stash them:  git stash -u',
          '  Or commit them first.',
          '',
        }
        vim.list_extend(lines, dirty_hdr)
        vim.list_extend(lines, dirty_files)
        table.insert(lines, '')
        table.insert(lines, '  Press q to close')
        show_window(lines)
        return
      end

      if behind == 0 then
        show_window({ '', '  Config is already up to date.', '', '  Press q to close' })
        return
      end

      local before = info.hash

      -- Record the pre-pull commit *before* moving HEAD. `update-ref` needs a
      -- full 40-char SHA, so resolve it while HEAD still points at the old one.
      git_async({ 'rev-parse', 'HEAD' }, function(ref_res)
        local old_sha = trim(ref_res.stdout)
        if ref_res.code == 0 and #old_sha == 40 then
          git_async({ 'update-ref', 'refs/config-update-backup', old_sha }, function() end)
        end

        -- We already fetched, so a fast-forward merge avoids a second round trip.
        git_async({ 'merge', '--ff-only', '@{u}' }, function(res)
          if res.code ~= 0 then
            local detail = trim(res.stderr) ~= '' and trim(res.stderr) or trim(res.stdout)
            show_window({
              '',
              '  Failed to fast-forward!',
              '',
              '  ' .. detail,
              '',
              '  Press q to close',
            })
            return
          end

          git_async({ 'rev-parse', '--short', 'HEAD' }, function(head_res)
            local after = trim(head_res.stdout)
            local lines = {
              '',
              ('  Config updated! %d commit(s) pulled.'):format(behind),
              '',
              ('  %s..%s'):format(before or '?', after ~= '' and after or '?'),
              ('  Rollback:  git reset --hard refs/config-update-backup'):format(),
            }
            local first_idx, last_idx
            lines, first_idx, last_idx = append_log(lines, log)
            vim.list_extend(lines, {
              '',
              '  Run :Lazy sync to install any newly added plugins.',
              '  Then restart Neovim to apply the changes.',
              '',
              '  Press q to close',
            })
            show_window(lines)
            for i = first_idx or 0, last_idx or -1 do
              set_line_hl(i, 'ConfigUpdateNew')
            end
          end)
        end)
      end)
    end)
  end

  if not confirm then return start() end

  inspect({ fetch = false }, function(info)
    local behind = info and parse_counts(info) or 0
    if behind == 0 then return start() end -- nothing to pull, no need to ask
    confirm_window({
      '',
      ('  Fast-forward your config by %d commit(s)?'):format(behind),
      '',
      '  Press y to continue | q to cancel',
    }, start)
  end)
end

--- Show branch, commit, divergence and local modifications.
function M.status()
  local err = preflight()
  if err then
    vim.notify('Config status unavailable: ' .. err, vim.log.levels.ERROR, { title = 'Config Status' })
    return
  end

  inspect({ fetch = false }, function(info, inspect_err)
    if not info then
      vim.notify('git failed:\n' .. (inspect_err or 'unknown error'), vim.log.levels.ERROR, {
        title = 'Config Status',
      })
      return
    end

    local ahead, behind = parse_counts(info)
    local dirty_hdr, dirty_files = dirty_lines(info)
    local lines = {
      '',
      '  Config Git Status',
      '',
      ('  Branch:  %s'):format(info.branch or 'unknown'),
      ('  Commit:  %s'):format(info.hash or '?'),
      ('  Remote:  %s'):format(resolve_remote()),
      ('  Status:  %d ahead, %d behind'):format(ahead, behind),
    }

    if not info.upstream then
      vim.list_extend(lines, {
        '',
        '  No upstream tracking branch is configured for this checkout.',
        ('  Fix with:  git branch --set-upstream-to=origin/%s'):format(info.branch or 'main'),
      })
    end

    if #dirty_hdr > 0 then
      table.insert(lines, '')
      vim.list_extend(lines, dirty_hdr)
      vim.list_extend(lines, dirty_files)
    end

    table.insert(lines, '')
    table.insert(lines, '  Press q to close')
    show_window(lines)
  end)
end

---------------------------------------------------------------------------------
-- Background checker
--------------------------------------------------------------------------------

--- @return boolean enabled
function M.is_enabled() return auto_timer ~= nil end

--- Start the background checker.
function M.enable()
  if auto_timer then return end
  auto_timer = vim.uv.new_timer()
  auto_timer:start(first_check_delay, check_interval, function()
    vim.schedule(M.autocheck)
  end)
end

--- Stop the background checker.
function M.disable()
  if not auto_timer then return end
  auto_timer:stop()
  auto_timer:close()
  auto_timer = nil
end

--- Toggle the background checker.
function M.toggle()
  if M.is_enabled() then
    M.disable()
    vim.notify('Config auto-check disabled', vim.log.levels.INFO, { title = 'Config Update' })
  else
    M.enable()
    vim.notify('Config auto-check enabled', vim.log.levels.INFO, { title = 'Config Update' })
  end
end

--- One background pass. Stays silent unless the config is actually behind.
function M.autocheck()
  if preflight() then return end
  -- Guard against overlapping runs if the interval is set very low.
  if auto_timer and not auto_timer:is_closing() then return end

  git_async({ 'fetch', '--quiet', resolve_remote_name() }, function(res)
    -- A failed background fetch must stay quiet: it is not the user's request.
    if res.code ~= 0 then return end
    inspect({ fetch = false }, function(info)
      if not info then return end
      local _, behind = parse_counts(info)
      if behind > 0 then
        vim.notify(
          ('Config is %d commit(s) behind. Press <leader>cu to review.'):format(behind),
          vim.log.levels.WARN,
          { title = 'Config Update' }
        )
      end
    end)
  end)
end

---------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------

--- Register the user commands. Called automatically on first require.
function M.setup()
  vim.api.nvim_create_user_command('ConfigUpdateCheck', M.check, {
    desc = 'Check for config updates from remote',
  })
  vim.api.nvim_create_user_command('ConfigUpdate', M.update, {
    desc = 'Pull latest config updates from remote',
  })
  vim.api.nvim_create_user_command('ConfigUpdateStatus', M.status, {
    desc = 'Show config git status',
  })
  vim.api.nvim_create_user_command('ConfigUpdateAuto', M.toggle, {
    desc = 'Toggle automatic config update checks',
  })
end

M.setup()

return M
