--- package.json bau actions

local M = {}

-- Backend - terminal tasks performed on option selected
function M.action(option)
  local utils = require 'custom.code_runner.utils'

  -- Run command
  local cmd = option
  utils.run_in_terminal(cmd)
end

return M
