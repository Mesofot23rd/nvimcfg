--- Shell language actions
-- This runner is only useful for simple stuff.
-- If you need to pass arguments to your shell script, just run it on the terminal.
-- You can always create a .solution file, but this would be an overkill in most cases.

local M = {}

--- Frontend - options displayed on fzf-lua
M.options = {
  { text = "Run this file", value = "option1" },
  { text = "Run solution",  value = "option2" }
}

--- Backend - terminal tasks performed on option selected
function M.action(selected_option)
  local utils = require("custom.code_runner.utils")
  local entry_point = utils.os_path(vim.fn.expand('%:p'), true)                  -- current buffer
  local arguments = ""                                                           -- arguments can be overriden in .solution


  if selected_option == "option1" then
    local cmd = entry_point
    utils.run_in_terminal(cmd)
  elseif selected_option == "option2" then
    local entry_points
    local tasks = {}
    local executables = {}

    -- if .solution file exists in working dir
    local solution_file = utils.get_solution_file()
    if solution_file then
      local config = utils.parse_solution_file(solution_file)

      for entry, variables in pairs(config) do
        if entry == "executables" then goto continue end
        entry_point = utils.os_path(variables.entry_point, true)
        arguments = variables.arguments or "" -- optional
        local cmd = (arguments == "" and "" or arguments .. " ") .. entry_point
        table.insert(tasks, cmd) -- store all the tasks we've created
        ::continue::
      end

      local solution_executables = config["executables"]
      if solution_executables then
        for _, executable in pairs(solution_executables) do
          executable = utils.os_path(executable, true)
          local cmd = executable
          table.insert(executables, cmd) -- store all the executables we've created
        end
      end

      local all_cmds = {}
      for _, cmd in ipairs(tasks) do table.insert(all_cmds, cmd) end
      for _, cmd in ipairs(executables) do table.insert(all_cmds, cmd) end
      utils.run_in_terminal(table.concat(all_cmds, " && "))

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.sh")

      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point, true)
        local cmd = entry_point
        table.insert(tasks, cmd) -- store all the tasks we've created
      end

      utils.run_in_terminal(table.concat(tasks, " && "))
    end
  end
end

return M
