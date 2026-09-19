--- Kotlin language action

local M = {}

--- Frontend - options displayed on fzf-lua
M.options = {
  { text = "Build and run program (class)", value = "option1" },
  { text = "Build program (class)", value = "option2" },
  { text = "Run program (class)", value = "option3" },
  { text = "Build solution (class)", value = "option4" },
  { text = "", value = "separator" },
  { text = "Build and run program (jar)", value = "option5" },
  { text = "Build program (jar)", value = "option6" },
  { text = "Run program (jar)", value = "option7" },
  { text = "Build solution (jar)", value = "option8" },
  { text = "", value = "separator" },
  { text = "Run REPL", value = "option9" }
}

--- Backend - terminal tasks performed on option selected
function M.action(selected_option)
  local utils = require("custom.code_runner.utils")
  local entry_point = utils.os_path(vim.fn.getcwd() .. "/Main.kt")           -- working_directory/Main.kt
  local files = utils.find_files_to_compile(entry_point, "*.kt")             -- *.kt files under entry_point_dir (recursively)
  local output_dir = utils.os_path(vim.fn.getcwd() .. "/bin/")               -- working_directory/bin/
  local output = utils.os_path(vim.fn.getcwd() .. "/bin/MainKt")             -- working_directory/bin/MainKt.class
  local output_filename = "MainKt"                                           -- working_directory/bin/MainKt
  local arguments = ""                                                       -- arguments can be overriden in .solution

  --========================== Build as class ===============================--
  if selected_option == "option1" then
    local cmd = "rm -f \"" .. output_dir .. "/*.class\" " .. " || true" ..                    -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                     -- mkdir
                " && kotlinc " .. files .. " -d \"" .. output_dir .. "\" " .. arguments  ..    -- compile bytecode
                " && java -cp \"" .. output_dir .. "\" " .. output_filename
    utils.run_in_terminal(cmd)
  elseif selected_option == "option2" then
    local cmd = "rm -f \"" .. output_dir .. "/*.class\" " .. " || true" ..                    -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                     -- mkdir
                " && kotlinc " .. files .. " -d \"" .. output_dir .. "\" " .. arguments
    utils.run_in_terminal(cmd)
  elseif selected_option == "option3" then
    local cmd = "java -cp \"" .. output_dir .. "\" " .. output_filename
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
        files = utils.find_files_to_compile(entry_point, "*.kt")
        output = utils.os_path(variables.output)
        output_dir = utils.os_path(output:match("^(.-[/\\])[^/\\]*$"))
        arguments = variables.arguments or arguments -- optional
        local cmd = "rm -f \"" .. output_dir .. "/*.class\"" .. " || true" ..                          -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                         -- mkdir
                " && kotlinc " .. files .. " -d \"" .. output_dir .. "\" " .. arguments .. " "
        table.insert(commands, cmd)
        ::continue::
      end

      local solution_executables = config["executables"]
      if solution_executables then
        for entry, executable in pairs(solution_executables) do
          output_dir = utils.os_path(executable:match("^(.-[/\\])[^/\\]*$"))
          output_filename = vim.fn.fnamemodify(executable, ":t:r")
          local cmd = "java -cp \"" .. output_dir .. "\" " .. output_filename
          table.insert(commands, cmd)
        end
      end

      utils.run_in_terminal(table.concat(commands, " && "))

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "Main.kt")

      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point)
        files = utils.find_files_to_compile(entry_point, "*.kt")
        output_dir = utils.os_path(entry_point:match("^(.-[/\\])[^/\\]*$") .. "bin")           -- entry_point/bin
        local cmd = "rm -f \"" .. output_dir .. "/*.class\"" .. " || true" ..                      -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                     -- mkdir
                " && kotlinc " .. files .. " -d \"" .. output_dir .. "\" " .. arguments
        table.insert(commands, cmd)
      end

      utils.run_in_terminal(table.concat(commands, " && "))
    end

  --=========================== Build as jar ================================--
  elseif selected_option == "option5" then
    local cmd = "rm -f \"" .. output .. "\" || true " ..                                       -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                     -- mkdir
                " && kotlinc " .. files .. " -include-runtime -d \"" .. output .. ".jar\" " .. arguments  ..  -- compile bytecode (jar)
                " && java -jar \"" .. output .. ".jar\""
    utils.run_in_terminal(cmd)
  elseif selected_option == "option6" then
    local cmd = "rm -f \"" .. output .. "\" || true " ..                                       -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                     -- mkdir
                " && kotlinc " .. files .. " -include-runtime -d \"" .. output .. ".jar\" " .. arguments
    utils.run_in_terminal(cmd)
  elseif selected_option == "option7" then
    local cmd = "java -jar \"" .. output .. ".jar\""
    utils.run_in_terminal(cmd)
  elseif selected_option == "option8" then
    local entry_points
    local commands = {}

    -- if .solution file exists in working dir
    local solution_file = utils.get_solution_file()
    if solution_file then
      local config = utils.parse_solution_file(solution_file)

      for entry, variables in pairs(config) do
        if entry == "executables" then goto continue end
        entry_point = utils.os_path(variables.entry_point)
        files = utils.find_files_to_compile(entry_point, "*.kt")
        output = utils.os_path(variables.output)
        output_dir = utils.os_path(output:match("^(.-[/\\])[^/\\]*$"))
        arguments = variables.arguments or arguments -- optional
        local cmd = "rm -f \"" .. output .. "\" || true " ..                                                  -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                                -- mkdir
                " && kotlinc " .. files .. " -include-runtime -d \"" .. output .. "\" " .. arguments
        table.insert(commands, cmd)
        ::continue::
      end

      local solution_executables = config["executables"]
      if solution_executables then
        for entry, executable in pairs(solution_executables) do

          local cmd = "java -jar \"" .. executable .. "\""
          table.insert(commands, cmd)
        end
      end

      utils.run_in_terminal(table.concat(commands, " && "))

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "Main.kt")

      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point)
        files = utils.find_files_to_compile(entry_point, "*.kt")
        output_dir = utils.os_path(entry_point:match("^(.-[/\\])[^/\\]*$") .. "bin")        -- entry_point/bin
        output = utils.os_path(output_dir .. "/Main")                                       -- entry_point/bin/MainKt.jar
        local cmd = "rm -f \"" .. output .. "\" || true " ..                                                      -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                                    -- mkdir
                " && kotlinc " .. files .. " -include-runtime -d \"" .. output .. ".jar\" " .. arguments
        table.insert(commands, cmd)
      end

      utils.run_in_terminal(table.concat(commands, " && "))
    end

  --========================== MISC ===============================--
  elseif selected_option == "option9" then
    local cmd = "kotlin "
    utils.run_in_terminal(cmd)
  end
end

return M
