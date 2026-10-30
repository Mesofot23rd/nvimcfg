---@type AstroThemeCallback
local function callback(...)
  return vim.tbl_deep_extend(
    "force",
    require "custom.theme.xnx-theme.groups.plugins.ministarter"(...),
    require "custom.theme.xnx-theme.groups.plugins.miniicons"(...)
  )
end

return callback
