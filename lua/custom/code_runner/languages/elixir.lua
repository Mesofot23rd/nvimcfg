--- Elixir language actions

local M = {}

--- Frontend - options displayed on fzf-lua
M.options = {
  { text = "Run this file", value = "option1" },
  { text = "Mix run", value = "option2" },
  { text = "Run REPL", value = "option3" }
}

--- Backend - terminal tasks performed on option selected
function M.action(selected_option)
  local utils = require("custom.code_runner.utils")
  local current_file = utils.os_path(vim.fn.expand('%:p'), true)             -- current file


  if selected_option == "option1" then
    local cmd = "elixir -r " .. current_file
    utils.run_in_terminal(cmd)
  elseif selected_option == "option2" then
    local cmd = "mix clean " ..                                              -- clean
                " && mix run "
    utils.run_in_terminal(cmd)
  elseif selected_option == "option3" then
    local cmd = "iex"                                                       -- run
    utils.run_in_terminal(cmd)
  end
end

return M
