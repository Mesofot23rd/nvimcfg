--- Makefile bau actions

local M = {}

-- Backend - terminal tasks performed on option selected
function M.action(option)
  local utils = require 'custom.code_runner.utils'
  local cmd = 'make ' .. option
  utils.run_in_terminal(cmd)
end

return M
