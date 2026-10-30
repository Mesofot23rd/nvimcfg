--- F# language actions

local M = {}

--- Frontend - options displayed on fzf-lua
M.options = {
  { text = "Build and run program (dotnet)", value = "option1" },
  { text = "Build program (dotnet)", value = "option2" },
  { text = "Run REPL", value = "option3" }
}

--- Backend - terminal tasks performed on option selected
function M.action(selected_option)
  local utils = require("custom.code_runner.utils")

  if selected_option == "option1" then
    local cmd = "dotnet run"
    utils.run_in_terminal(cmd)
  elseif selected_option == "option2" then
    local cmd = "dotnet build"
    utils.run_in_terminal(cmd)
  elseif selected_option == "option3" then
    local cmd = "echo 'To exit the REPL enter #q;;'" ..                      -- echo
                " ; dotnet fsi"
    utils.run_in_terminal(cmd)
  end
end

return M
