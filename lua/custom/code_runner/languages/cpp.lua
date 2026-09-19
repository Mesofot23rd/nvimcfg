--- C++ language actions

local M = {}

--- Frontend - options displayed on fzf-lua
M.options = {
  { text = 'Build and run program', value = 'option1' },
  { text = 'Build program', value = 'option2' },
  { text = 'Run program', value = 'option3' },
  { text = 'Build solution', value = 'option4' },
}

--- Backend - terminal tasks performed on option selected
function M.action(selected_option)
  local utils = require 'custom.code_runner.utils'
  local entry_point = utils.os_path(vim.fn.getcwd() .. '/main.cpp') -- working_directory/main.c
  local files = utils.find_files_to_compile(entry_point, '*.cpp', true) -- *.c files under entry_point_dir (recursively)
  local output_dir = utils.os_path(vim.fn.getcwd() .. '/bin/') -- working_directory/bin/
  local output = utils.os_path(vim.fn.getcwd() .. '/bin/program') -- working_directory/bin/program
  local arguments = '-Wall -g' -- arguments can be overridden in .solution

  if selected_option == 'option1' then
    local cmd = 'rm -f "'
      .. output
      .. '" || true' -- clean
      .. ' && mkdir -p "'
      .. output_dir
      .. '"' -- mkdir
      .. ' && g++ '
      .. files
      .. ' -o "'
      .. output
      .. '" '
      .. arguments -- compile
      .. ' && "'
      .. output
      .. '"'
    utils.run_in_terminal(cmd)
  elseif selected_option == 'option2' then
    local cmd = 'rm -f "'
      .. output
      .. '" || true' -- clean
      .. ' && mkdir -p "'
      .. output_dir
      .. '"' -- mkdir
      .. ' && g++ '
      .. files
      .. ' -o "'
      .. output
      .. '" '
      .. arguments
    utils.run_in_terminal(cmd)
  elseif selected_option == 'option3' then
    local cmd = '"' .. output .. '"'
    utils.run_in_terminal(cmd)
  elseif selected_option == 'option4' then
    local entry_points
    local cmds = {}

    -- if .solution file exists in working dir
    local solution_file = utils.get_solution_file()
    if solution_file then
      local config = utils.parse_solution_file(solution_file)

      for entry, variables in pairs(config) do
        if entry == 'executables' then
          goto continue
        end
        entry_point = utils.os_path(variables.entry_point)
        files = utils.find_files_to_compile(entry_point, '*.cpp')
        output = utils.os_path(variables.output)
        output_dir = utils.os_path(output:match '^(.-[/\\])[^/\\]*$')
        arguments = variables.arguments or arguments -- optional
        local cmd = 'rm -f "'
          .. output
          .. '" || true' -- clean
          .. ' && mkdir -p "'
          .. output_dir
          .. '"' -- mkdir
          .. ' && g++ '
          .. files
          .. ' -o "'
          .. output
          .. '" '
          .. arguments
        table.insert(cmds, cmd) -- store all the tasks we've created
        ::continue::
      end

      local solution_executables = config['executables']
      if solution_executables then
        for entry, executable in pairs(solution_executables) do
          executable = utils.os_path(executable, true)
          local cmd = executable
          table.insert(cmds, cmd) -- store all the executables we've created
        end
      end

      utils.run_in_terminal(table.concat(cmds, ' && '))
    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), 'main.cpp')

      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point)
        files = utils.find_files_to_compile(entry_point, '*.cpp')
        output_dir = utils.os_path(entry_point:match '^(.-[/\\])[^/\\]*$' .. 'bin') -- entry_point/bin
        output = utils.os_path(output_dir .. '/program') -- entry_point/bin/program
        local cmd = 'rm -f "'
          .. output
          .. '" || true' -- clean
          .. ' && mkdir -p "'
          .. output_dir
          .. '"' -- mkdir
          .. ' && g++ '
          .. files
          .. ' -o "'
          .. output
          .. '" '
          .. arguments
        table.insert(cmds, cmd) -- store all the tasks we've created
      end

      utils.run_in_terminal(table.concat(cmds, ' && '))
    end
  end
end

return M
