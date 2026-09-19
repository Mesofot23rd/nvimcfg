--- Dart/Flutter language actions

local M = {}

--- Frontend - options displayed on fzf-lua
M.options = {
  { text = "Run this file (interpreted)", value = "option1" },
  { text = "Run program (interpreted)", value = "option2" },
  { text = "Build solution (interpreted)", value = "option3" },
  { text = "", value = "separator" },
  { text = "Build and run program (machine code)", value = "option4" },
  { text = "Build program (machine code)", value = "option5" },
  { text = "Run program (machine code)", value = "option6" },
  { text = "Build solution (machine code)", value = "option7" },
  { text = "", value = "separator" },
  { text = "Run program (flutter)", value = "option8" },
  { text = "Build for linux (flutter)", value = "option9" },
  { text = "Build for android (flutter)", value = "option10" },
  { text = "Build for ios (flutter)", value = "option11" },
  { text = "Build for web (flutter)", value = "option12" },
  { text = "", value = "separator" },
  { text = "Transpile program to javascript", value = "option13" }
}

--- Backend - terminal tasks performed on option selected
function M.action(selected_option)
  local utils = require("custom.code_runner.utils")
  local current_file = utils.os_path(vim.fn.expand('%:p'), true)                -- current file
  local entry_point = utils.os_path(vim.fn.getcwd() .. "/lib/main.dart", true)  -- working_directory/lib/main.dart
  local output_dir = utils.os_path(vim.fn.getcwd() .. "/bin/")                  -- working_directory/bin/
  local output = utils.os_path(vim.fn.getcwd() .. "/bin/main")                  -- working_directory/bin/main


  --=========================== INTERPRETED =================================--
  if selected_option == "option1" then
    local cmd = "dart " .. current_file 
    utils.run_in_terminal(cmd)
  elseif selected_option == "option2" then
    local cmd = "dart " .. entry_point 
    utils.run_in_terminal(cmd)
  elseif selected_option == "option3" then
    local entry_points
    local commands = {}

    -- if .solution file exists in working dir
    local solution_file = utils.get_solution_file()
    if solution_file then
      local config = utils.parse_solution_file(solution_file)

      for entry, variables in pairs(config) do
        if entry == "executables" then goto continue end
        entry_point = utils.os_path(variables.entry_point, true)
        local arguments = variables.arguments or "" -- optional
        local cmd = "dart " .. arguments .. " " .. entry_point 
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
      entry_points = utils.find_files(vim.fn.getcwd(), "main.dart")
      local arguments = ""
      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point, true)
        local cmd = "dart " .. arguments .. " " .. entry_point 
        table.insert(commands, cmd)
      end

      utils.run_in_terminal(table.concat(commands, " && "))
    end

  --========================== MACHINE CODE =================================--
  elseif selected_option == "option4" then
    local arguments = "" -- optional
    local cmd = "rm -f \"" .. output .. "\" || true" ..                            -- clean
              " && mkdir -p \"" .. output_dir .. "\"" ..                           -- mkdir
              " && dart compile exe " .. entry_point .. " -o \"" .. output .. "\" " .. arguments .. -- compile
              " && \"" .. output .. "\"" 
    utils.run_in_terminal(cmd)
  elseif selected_option == "option5" then
    local arguments = "" -- optional
    local cmd = "rm -f \"" .. output .. "\" || true" ..                            -- clean
              " && mkdir -p \"" .. output_dir .. "\"" ..                           -- mkdir
              " && dart compile exe " .. entry_point .. " -o \"" .. output .. "\" " .. arguments 
    utils.run_in_terminal(cmd)
  elseif selected_option == "option6" then
    local arguments = "" -- optional
    local cmd = "\"" .. output .. "\"" 
    utils.run_in_terminal(cmd)
  elseif selected_option == "option7" then
    local entry_points
    local commands = {}

    -- if .solution file exists in working dir
    local solution_file = utils.get_solution_file()
    if solution_file then
      local config = utils.parse_solution_file(solution_file)

      for entry, variables in pairs(config) do
        if entry == "executables" then goto continue end
        entry_point = utils.os_path(variables.entry_point, true)
        output = utils.os_path(variables.output)
        output_dir = utils.os_path(output:match("^(.-[/\\])[^/\\]*$"))
        local arguments = variables.arguments or "" -- optional
        local cmd = "rm -f \"" .. output ..  "\" || true" ..                             -- clean
                " && mkdir -p " .. output_dir ..                                     -- mkdir
                " && dart compile exe " .. entry_point .. " -o \"" .. output .. "\" " .. arguments 
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
      entry_points = utils.find_files(vim.fn.getcwd(), "main.dart")
      local arguments = ""
      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point)
        output_dir = utils.os_path(entry_point:match("^(.-[/\\])[^/\\]*$") .. "../bin")                   -- entry_point/../bin
        output = utils.os_path(output_dir .. "/main")                                                     -- entry_point/bin/main
        local cmd ="rm -f \"" .. output ..  "\" || true" ..                                                   -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                                -- mkdir
                " && dart compile exe \"" .. entry_point .. "\" -o \"" .. output .. "\" " .. arguments 
        table.insert(commands, cmd)
      end

      utils.run_in_terminal(table.concat(commands, " && "))
    end

  --============================= FLUTTER ===================================--
  elseif selected_option == "option8" then
    local cmd = "flutter run " 
    utils.run_in_terminal(cmd)
  elseif selected_option == "option9" then
    local cmd = "flutter build linux" 
    utils.run_in_terminal(cmd)
  elseif selected_option == "option10" then
    local cmd = "flutter build apk" 
    utils.run_in_terminal(cmd)
  elseif selected_option == "option11" then
    local cmd = "flutter build ios" 
    utils.run_in_terminal(cmd)
  elseif selected_option == "option12" then
    local cmd = "flutter build web" 
    utils.run_in_terminal(cmd)

  --= ================== TRANSPILE (TO JAVASCRIPT) ==========================--
  elseif selected_option == "option13" then
    local cmd = "dart compile js -o \"" .. output_dir .. "/js/\" "  .. entry_point 
    utils.run_in_terminal(cmd)
  end
end

return M
