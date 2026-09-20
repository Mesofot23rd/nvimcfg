local env = require 'custom.statusline_components.env'
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
  -- print(sysname)

  local sysname = vim.uv.os_uname().sysname
  -- local sysname = vim.uv.os_gethostname()

  if sysname:match 'Darwin' then
    return ''
  elseif sysname:match 'Windows' then
    return ''
  elseif sysname:match 'Windows_NT' then
    return ''
  elseif sysname:match 'OpenBSD' then
    return 'BSD'
  elseif sysname:match 'Linux' then
    local release = vim.loop.os_uname().release

    if release:lower():match 'arch' then return '' end
    if vim.fn.has 'Android' == 1 then return '󱚟' end

    return ''
  else
    return ''
  end
end

return M
