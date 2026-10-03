local env = require 'custom.statusline.env'
local M = {}

--- Get an icon from given its icon name.
---@param name string The name of the icon to retrieve.
---@return string icon.
function M.get_icon(name) return env.icons[name] or '' end

--- Check if a plugin is defined in lazy. Useful with lazy loading
--- when a plugin is not necessarily loaded yet.
---@param plugin string The plugin to search for.
---@return boolean available # Whether the plugin is available.
function M.is_available(plugin)
  local lazy_config_avail, lazy_config = pcall(require, 'lazy.core.config')
  return lazy_config_avail and lazy_config.spec.plugins[plugin] ~= nil
end

--- Get the OS icon based on the current system.
---@return string icon.
function M.get_os_icon()
  -- local sysname = vim.uv.os_gethostname()
  local sysname = vim.uv.os_uname().sysname
  local os_icon = ''

  if sysname:match 'Darwin' then
    os_icon = ''
  elseif vim.fn.has 'win32' == 1 then
    os_icon ''
  elseif vim.fn.has 'Android' == 1 then
    os_icon = '󱚟'
  elseif sysname:match 'OpenBSD' then
    os_icon 'BSD'
  elseif sysname:match 'Linux' then
    os_icon = ''
    local release = vim.uv.os_gethostname()
    if release:lower():find 'arch' then os_icon = '' end
  end

  return os_icon
end

return M
