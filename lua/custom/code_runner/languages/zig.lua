--- Zig language actions
--- Note: You must initialize your project with:
--  'zig init-exe' or 'zig init-lib'
--- to use the compiler options defined here.

local M = {}

--- Frontend - options displayed on fzf-lua
M.options = {
  { text = 'Zig build and run program', value = 'option1' },
  { text = 'Zig build program', value = 'option2' },
}

--- Backend - terminal tasks performed on option selected
function M.action(selected_option)
  local utils = require 'custom.code_runner.utils'
  local arguments = ''

  if selected_option == 'option1' then
    local cmd = 'zig build run ' .. arguments
    utils.run_in_terminal(cmd)
  elseif selected_option == 'option2' then
    local cmd = 'zig build ' .. arguments
    utils.run_in_terminal(cmd)
  end
end

return M
