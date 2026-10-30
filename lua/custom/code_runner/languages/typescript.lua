--- Typescript language actions

local M = {}

--- Frontend - options displayed on fzf-lua
M.options = {
  { text = "Run this file", value = "option1" },
  { text = "Run program",   value = "option2" }
}

--- Backend - terminal tasks performed on option selected
function M.action(selected_option)
  local utils = require("custom.code_runner.utils")
  local current_file = vim.fn.expand('%:p')                                  -- current file
  local entry_point = utils.os_path(vim.fn.getcwd() .. "/src/index.ts")      -- working_directory/index.ts
  local output_dir = utils.os_path(vim.fn.getcwd() .. "/dist/")              -- working_directory/dist/
  local arguments = "--outDir " .. utils.os_path(output_dir, true)

  if selected_option == "option1" then
    local current_file_js = output_dir .. vim.fn.fnamemodify(current_file, ":t:r") .. ".js"
    local cmd = "npx tsc " .. arguments ..                                   -- transpile to js
                " && node \"" .. current_file_js .. "\""
    utils.run_in_terminal(cmd)
  elseif selected_option == "option2" then
    local entry_point_js =  output_dir .. vim.fn.fnamemodify(entry_point, ":t:r") .. ".js"
    local cmd = "npx tsc " .. arguments ..                                   -- transpile to js
                " && node \"" .. entry_point_js .. "\""
    utils.run_in_terminal(cmd)
  end

end

return M
