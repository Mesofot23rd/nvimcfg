--- Go language actions

local M = {}

--- Frontend - options displayed on fzf-lua
M.options = {
  { text = "Build and run program", value = "option1" },
  { text = "Build program", value = "option2" },
  { text = "Run program", value = "option3" },
  { text = "Build solution", value = "option4" }
}

--- Backend - terminal tasks performed on option selected
function M.action(selected_option)
  local utils = require("custom.code_runner.utils")
  local entry_point = utils.os_path(vim.fn.getcwd() .. "/main.go", true)     -- working_directory/main.go
  local files = utils.find_files_to_compile(entry_point, "*.go")             -- *.go files under entry_point_dir (recursively)
  local output_dir = utils.os_path(vim.fn.getcwd() .. "/bin/", true)         -- working_directory/bin/
  local output = utils.os_path(vim.fn.getcwd() .. "/bin/program", true)      -- working_directory/bin/program
  local arguments = "-a -gcflags='-N -l'"                                    -- arguments can be overriden in .solution


  if selected_option == "option1" then
    local cmd = "rm -f " .. output ..                                                    -- clean
                " && mkdir -p " .. output_dir ..                                         -- mkdir
                " && go build " .. arguments .. " -o " .. output .. " " .. files ..      -- compile
                " && " .. output
    utils.run_in_terminal(cmd)
  elseif selected_option == "option2" then
    local cmd = "rm -f " .. output ..                                                    -- clean
                " && mkdir -p " .. output_dir ..                                         -- mkdir
                " && go build " .. arguments .. " -o " .. output .. " " .. files
    utils.run_in_terminal(cmd)
  elseif selected_option == "option3" then
    local cmd = output
    utils.run_in_terminal(cmd)
  elseif selected_option == "option4" then
    local entry_points
    local commands = {}

    -- if .solution file exists in working dir
    local solution_file = utils.get_solution_file()
    if solution_file then
      local config = utils.parse_solution_file(solution_file)

      for entry, variables in pairs(config) do
        if entry == "executables" then goto continue end
        entry_point = utils.os_path(variables.entry_point)
        files = utils.find_files_to_compile(entry_point, "*.go")
        output = utils.os_path(variables.output)
        output_dir = utils.os_path(output:match("^(.-[/\\])[^/\\]*$"))
        arguments = variables.arguments or arguments -- optional
        local cmd = "rm -f \"" .. output .. "\"" ..                                          -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                               -- mkdir
                " && go build " .. arguments .. " -o \"" .. output .. "\" " .. files
        table.insert(commands, cmd)
        ::continue::
      end

      local solution_executables = config["executables"]
      if solution_executables then
        for entry, executable in pairs(solution_executables) do
          executable = utils.os_path(executable, true)
          local cmd = executable
          table.insert(commands, cmd)
        end
      end

      utils.run_in_terminal(table.concat(commands, " && "))

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.go")

      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point)
        files = utils.find_files_to_compile(entry_point, "*.go")
        output_dir = utils.os_path(entry_point:match("^(.-[/\\])[^/\\]*$") .. "bin")     -- entry_point/bin
        output = utils.os_path(output_dir .. "/program")                                 -- entry_point/bin/program
        local cmd = "rm -f \"" .. output .. "\"" ..                                          -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                               -- mkdir
                " && go build " .. arguments .. " -o \"" .. output .. "\" " .. files
        table.insert(commands, cmd)
      end

      utils.run_in_terminal(table.concat(commands, " && "))
    end
  end
end

return M
