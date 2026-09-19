--- Gleam language actions

local M = {}

-- Frontend - options displayed on fzf-lua
M.options = {
  { text = "Build and run program", value = "option1" },
  { text = "Build program", value = "option2" },
  { text = "Run program", value = "option3" },
}

-- Backend - terminal tasks performed on option selected
function M.action(selected_option)
  local utils = require("custom.code_runner.utils")

  if selected_option == "option1" then
    local cmd = "gleam build " ..                                            -- compile
                " && gleam run"
    utils.run_in_terminal(cmd)
  elseif selected_option == "option2" then
    local cmd = "gleam build "
    utils.run_in_terminal(cmd)
  elseif selected_option == "option3" then
    local cmd = "gleam run "
    utils.run_in_terminal(cmd)
   end
end

return M

