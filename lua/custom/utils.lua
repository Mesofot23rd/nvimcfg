M = {}

--------------------------------------------------------------------------------------
-- local os_name = vim.loop.os_uname().sysname
-- local os_release = vim.loop.os_uname().release
-- local os_version = vim.loop.os_uname().version
-- local cpu_architecture = vim.loop.os_uname().machine

-- local hostname = vim.loop.os_gethostname()
-- local env_var = vim.loop.os_getenv ''

-- M.os = {
--   name = os_name,

--   is_macos = vim.fn.has 'mac' > 0,
--   is_windows = vim.fn.has 'win32' > 0 or vim.fn.has 'win64' > 0,
--   -- is_bsd = vim.fn.has 'bsd' > 0,
--   -- is_android = system('uname -o'):match('Android')

--   is_mac = os_name == 'Darwin',
--   is_linux = os_name == 'Linux',
--   is_windows = os_name == 'Windows_NT',
--   is_wsl = vim.fn.has 'wsl' == 1,
-- }
-- local function check_os()
--   local os_name = vim.loop.os_uname().sysname
--   local distro_name = ''

--   if os_name == 'Linux' then
--     -- Check for Android
--     local handle = io.popen 'uname -o'
--     local result = handle:read '*a'
--     handle:close()

--     if result == 'Android' then os_name = result end
--   elseif os_name == 'Darwin' then
--     return 'Operating System: macOS'
--   elseif os_name == 'Windows_NT' then
--     return 'Operating System: Windows'
--   elseif os_name == 'FreeBSD' then
--     return 'Operating System: BSD'
--   elseif os_name == 'Android' then
--     return 'Operating System: Android/Termux'
--   else
--     return 'Operating System: Unknown'
--   end
-- end

-- -- Example usage
-- print(check_os())

--------------------------------------------------------------------------------------
--- Toggle laststatus=3|2|0
function M.toggle_statusline()
  local laststatus = vim.opt.laststatus:get()
  local status
  if laststatus == 0 then
    vim.opt.laststatus = 2
    status = 'LOCAL'
  elseif laststatus == 2 then
    vim.opt.laststatus = 3
    status = 'GLOBAL'
  elseif laststatus == 3 then
    vim.opt.laststatus = 0
    status = 'OFF'
  end
end

--------------------------------------------------------------------------------------
--- Toggle URL highlight
function M.toggle_url_hl()
  vim.g.url_hl_enabled = not vim.g.url_hl_enabled
  require('base.utils').set_url_hl()
end

--------------------------------------------------------------------------------------
local notify_state
--- Toggle notifications
function M.toggle_notifications()
  vim.g.notifications_enabled = not vim.g.notifications_enabled
  if vim.g.notifications_enabled then
    vim.notify = notify_state
  else
    notify_state = vim.notify
  end
end

--------------------------------------------------------------------------------------
--- Toggle line numbers
function M.toggle_line_numbers()
  local number = vim.wo.number
  local relativenumber = vim.wo.relativenumber
  if not number and not relativenumber then -- mode 1
    vim.wo.number = true
  elseif number and not relativenumber then -- mode 2
    vim.wo.relativenumber = true
  elseif number and relativenumber then
    vim.wo.number = false -- mode 3
  else -- not number and relativenumber
    vim.wo.relativenumber = false -- mode 4
  end
end

--------------------------------------------------------------------------------------
--- Toggle spell
function M.toggle_spell() vim.wo.spell = not vim.wo.spell end

--------------------------------------------------------------------------------------
--- Set a highlight to apply to URLs.
-- function M.set_url_hl()
--   --- regex used for matching a valid URL/URI string
--   local url_matcher = '\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)'
--     .. '%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)'
--     .. '[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|'
--     .. '[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)'
--     .. '|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*'
--     .. '|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+'
--
--   M.delete_url_hl()
--   if vim.g.url_hl_enabled then -- set url hl
--     vim.api.nvim_set_hl(0, 'HighlightURL', { underline = true, bg = 'NONE' })
--     vim.fn.matchadd('HighlightURL', url_matcher, 15)
--   end
-- end
--
-- --- Delete the syntax matching rules for URLs/URIs if set.
-- function M.delete_url_hl()
--   for _, match in ipairs(vim.fn.getmatches()) do
--     if match.group == 'HighlightURL' then
--       vim.fn.matchdelete(match.id)
--     end
--   end
-- end
--

--------------------------------------------------------------------------------------
function M.run_command_in_terminal(cmd)
  -- cmd[command ]
  -- count
  -- size
  -- dir
  -- direction
  -- name
  -- go_back _ whether or not to return to original window
  -- open _ whether or not to open terminal window

  require('toggleterm').exec(cmd, 13, vim.o.columns * 0.4, nil, 'vertical', nil, true)
end

--------------------------------------------------------------------------------------

---Log error message
---@param message string
function M.log_error(message, name) vim.notify(name .. ' ' .. message, vim.log.levels.ERROR, { title = name }) end

---Log warning message
---@param message string
function M.log_warn(message, name) vim.notify(name .. ' ' .. message, vim.log.levels.WARN, { title = name }) end

---Log info message
---@param message string
function M.log_info(message, name) vim.notify(name .. ' ' .. message, vim.log.levels.INFO, { title = name }) end

return M
