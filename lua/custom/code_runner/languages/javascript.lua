--- Javascript language actions

local M = {}

--- Frontend - options displayed on fzf-lua
M.options = {
  { text = "Run this file", value = "option1" },
  { text = "Run program",   value = "option2" }
}

--- Backend - terminal tasks performed on option selected
function M.action(selected_option)
  local utils = require("custom.code_runner.utils")
  local current_file = utils.os_path(vim.fn.expand('%:p'), true)               -- current file
  local entry_point = utils.os_path(vim.fn.getcwd() .. "/src/index.js", true)  -- working_directory/index.js
  local arguments = ""

  if selected_option == "option1" then
    local cmd = "node " .. arguments .. " " .. current_file
    utils.run_in_terminal(cmd)
  elseif selected_option == "option2" then
    local cmd = "node " .. arguments .. " " .. entry_point
    utils.run_in_terminal(cmd)
  end

end

return M
