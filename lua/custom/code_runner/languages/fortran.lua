--- Fortran language actions

local M = {}

-- Frontend - options displayed on fzf-lua
M.options = {
  { text = "Run this file", value = "option1" },
  { text = "FPM build and run", value = "option2" },
  { text = "FPM build", value = "option3" },
  { text = "FPM run", value = "option4" },
}

-- Backend - terminal tasks performed on option selected
function M.action(selected_option)
  local utils = require("custom.code_runner.utils")
  local current_file = utils.os_path(vim.fn.expand('%:p'), true)                           -- current file
  local output_dir = utils.os_path(vim.fn.stdpath("cache") .. "/compiler/fortran/")        -- working_directory/bin/
  local output = output_dir .. "program"                                                   -- working_directory/bin/program
  local arguments = ""                                                                     -- arguments can be overriden in .solution

  if selected_option == "option1" then
    local cmd = "rm -f \"" .. output ..  "\" || true" ..                                   -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                 -- mkdir
                " && gfortran " .. current_file .. " -o \"" .. output .. "\" " .. arguments .. -- compile
                " && " .. output
    utils.run_in_terminal(cmd)
  elseif selected_option == "option2" then
    local cmd = "fpm build " ..                                              -- compile
                " && fpm run"
    utils.run_in_terminal(cmd)
  elseif selected_option == "option3" then
    local cmd = "fpm build "
    utils.run_in_terminal(cmd)
  elseif selected_option == "option4" then
    local cmd = "fpm run "
    utils.run_in_terminal(cmd)
   end
end

return M
