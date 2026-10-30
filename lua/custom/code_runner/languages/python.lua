--- Python language actions
-- Unlike most languages, python can be:
--   * interpreted
--   * compiled to machine code
--   * compiled to bytecode

local M = {}

--- Frontend - options displayed on fzf-lua
M.options = {
  { text = "Run this file (interpreted)", value = "option1" },
  { text = "Run program (interpreted)", value = "option2" },
  { text = "Run solution (interpreted)", value = "option3" },
  { text = "", value = "separator" },
  { text = "Build and run program (machine code)", value = "option4" },
  { text = "Build program (machine code)", value = "option5" },
  { text = "Run program (machine code)", value = "option6" },
  { text = "Build solution (machine code)", value = "option7" },
  { text = "", value = "separator" },
  { text = "Build and run program (bytecode)", value = "option8" },
  { text = "Build program (bytecode)", value = "option9" },
  { text = "Run program (bytecode)", value = "option10" },
  { text = "Build solution (bytecode)", value = "option11" },
  { text = "", value = "separator" },
  { text = "Run REPL", value = "option12" }
}

--- Backend - terminal tasks performed on option selected
function M.action(selected_option)
  local utils = require("custom.code_runner.utils")
  local current_file = utils.os_path(vim.fn.expand('%:p'), true)             -- current file
  local entry_point = utils.os_path(vim.fn.getcwd() .. "/main.py")           -- working_directory/main.py
  local files = utils.find_files_to_compile(entry_point, "*.py")             -- *.py files under entry_point_dir (recursively)
  local output_dir = utils.os_path(vim.fn.getcwd() .. "/bin/")               -- working_directory/bin/
  local output = utils.os_path(vim.fn.getcwd() .. "/bin/program")            -- working_directory/bin/program
  -- For python, arguments are not globally defined,
  -- as we have 3 different ways to run the code.


  --=========================== INTERPRETED =================================--
  if selected_option == "option1" then
    local cmd =  "python " .. current_file
    utils.run_in_terminal(cmd)
  elseif selected_option == "option2" then
    local cmd = "python \"" .. entry_point .. "\""
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
        local cmd = "python " .. arguments .. " " .. entry_point
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
      entry_points = utils.find_files(vim.fn.getcwd(), "main.py")
      local arguments = ""
      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point, true)
        local cmd = "python " .. arguments .. " " .. entry_point
        table.insert(commands, cmd)
      end

      utils.run_in_terminal(table.concat(commands, " && "))
    end

  --========================== MACHINE CODE =================================--
  elseif selected_option == "option4" then
    local arguments = "--warn-implicit-exceptions --warn-unusual-code"                  -- optional
    local cmd = "rm -f \"" .. output ..  "\" || true" ..                                -- clean
            " && mkdir -p \"" .. output_dir .. "\"" ..                                  -- mkdir
            " && nuitka --no-pyi-file --remove-output --follow-imports"  ..            -- compile to machine code
              " --output-filename=\"" .. output  .. "\"" ..
              " " .. arguments .. " " .. "\"" .. entry_point .. "\"" ..
            " && \"" .. output .. "\""
    utils.run_in_terminal(cmd)
  elseif selected_option == "option5" then
    local arguments = "--warn-implicit-exceptions --warn-unusual-code"                  -- optional
    local cmd = "rm -f \"" .. output ..  "\" || true" ..                                -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                              -- mkdir
                " && nuitka --no-pyi-file --remove-output --follow-imports"  ..        -- compile to machine code
                  " --output-filename=\"" .. output  .. "\"" ..
                  " " .. arguments .. " \"" .. entry_point .. "\""
    utils.run_in_terminal(cmd)
  elseif selected_option == "option6" then
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
        entry_point = utils.os_path(variables.entry_point)
        output = utils.os_path(variables.output)
        output_dir = utils.os_path(output:match("^(.-[/\\])[^/\\]*$"))
        local arguments = variables.arguments or "--warn-implicit-exceptions --warn-unusual-code" -- optional
        local cmd = "rm -f \"" .. output ..  "\" || true" ..                                -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                              -- mkdir
                " && nuitka --no-pyi-file --remove-output --follow-imports"  ..        -- compile to machine code
                " --output-filename=\"" .. output .. "\"" ..
                " " .. arguments .. " \"" .. entry_point .. "\""
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
      entry_points = utils.find_files(vim.fn.getcwd(), "main.py")

      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point)
        output_dir = utils.os_path(entry_point:match("^(.-[/\\])[^/\\]*$") .. "bin")    -- entry_point/bin
        output = utils.os_path(output_dir .. "/program")                                -- entry_point/bin/program
        local arguments = "--warn-implicit-exceptions --warn-unusual-code"              -- optional
        local cmd = "rm -f \"" .. output ..  "\" || true" ..                                -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                              -- mkdir
                " && nuitka --no-pyi-file --remove-output --follow-imports"  ..        -- compile to machine code
                  " --output-filename=\"" .. output  .. "\"" ..
                  " " .. arguments .. " \"" .. entry_point .. "\""
        table.insert(commands, cmd)
      end

      utils.run_in_terminal(table.concat(commands, " && "))
    end

  --============================ BYTECODE ===================================--
  elseif selected_option == "option8" then
    local cache_dir = utils.os_path(vim.fn.stdpath "cache" .. "/compiler/pyinstall/")
    local output_filename = vim.fn.fnamemodify(output, ":t")
    local arguments = "--log-level WARN --python-option W" -- optional
    local cmd = "rm -f \"" .. output ..  "\" || true" ..                                -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                              -- mkdir
                " && mkdir -p \"" .. cache_dir .. "\"" ..
                " && pyinstaller " .. files ..                                          -- compile to bytecode
                  " --name " .. output_filename ..
                  " --workpath \"" .. cache_dir .. "\"" ..
                  " --specpath \"" .. cache_dir .. "\"" ..
                  " --onefile --distpath \"" .. output_dir .. "\" " .. arguments ..
                " && \"" .. output .. "\""
    utils.run_in_terminal(cmd)
  elseif selected_option == "option9" then
    local cache_dir = utils.os_path(vim.fn.stdpath "cache" .. "/compiler/pyinstall/")
    local output_filename = vim.fn.fnamemodify(output, ":t")
    local arguments = "--log-level WARN --python-option W" -- optional
    local cmd = "rm -f \"" .. output ..  "\" || true" ..                                -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                              -- mkdir
                " && mkdir -p \"" .. cache_dir .. "\"" ..
                " && pyinstaller " .. files ..                                          -- compile to bytecode
                  " --name " .. output_filename ..
                  " --workpath \"" .. cache_dir .. "\"" ..
                  " --specpath \"" .. cache_dir .. "\"" ..
                  " --onefile --distpath \"" .. output_dir .. "\" " .. arguments
    utils.run_in_terminal(cmd)
  elseif selected_option == "option10" then
    local cmd = "\"" .. output .. "\""
    utils.run_in_terminal(cmd)
  elseif selected_option == "option11" then
    local entry_points
    local commands = {}

    -- if .solution file exists in working dir
    local solution_file = utils.get_solution_file()
    if solution_file then
      local config = utils.parse_solution_file(solution_file)

      for entry, variables in pairs(config) do
        if entry == "executables" then goto continue end
        local cache_dir = utils.os_path(vim.fn.stdpath "cache" .. "/compiler/pyinstall/")
        entry_point = utils.os_path(variables.entry_point)
        files = utils.find_files_to_compile(entry_point, "*.py")
        output = utils.os_path(variables.output)
        local output_filename = vim.fn.fnamemodify(output, ":t")
        output_dir = utils.os_path(output:match("^(.-[/\\])[^/\\]*$"))
        local arguments = variables.arguments or "--log-level WARN --python-option W"   -- optional
        local cmd = "rm -f \"" .. output ..  "\" || true" ..                                -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                              -- mkdir
                " && mkdir -p \"" .. cache_dir .. "\"" ..
                " && pyinstaller " .. files ..                                          -- compile to bytecode
                  " --name " .. output_filename ..
                  " --workpath \"" .. cache_dir .. "\"" ..
                  " --specpath \"" .. cache_dir .. "\"" ..
                  " --onefile --distpath \"" .. output_dir .. "\" " .. arguments
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
      entry_points = utils.find_files(vim.fn.getcwd(), "main.py")

      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point)
        files = utils.find_files_to_compile(entry_point, "*.py")
        output_dir = utils.os_path(entry_point:match("^(.-[/\\])[^/\\]*$") .. "bin")    -- entry_point/bin
        output = utils.os_path(output_dir .. "/program")                                -- entry_point/bin/program
        local cache_dir = utils.os_path(vim.fn.stdpath "cache" .. "/compiler/pyinstall/")
        local output_filename = vim.fn.fnamemodify(output, ":t")
        local arguments = "--log-level WARN --python-option W"                          -- optional
        local cmd = "rm -f \"" .. output ..  "\" || true" ..                                -- clean
                " && mkdir -p \"" .. cache_dir .. "\"" ..                               -- mkdir
                " && pyinstaller " .. files ..                                          -- compile to bytecode
                " --name " .. output_filename ..
                " --workpath \"" .. cache_dir .. "\"" ..
                " --specpath \"" .. cache_dir .. "\"" ..
                " --onefile --distpath \"" .. output_dir .. "\" " .. arguments
        table.insert(commands, cmd)
      end

      utils.run_in_terminal(table.concat(commands, " && "))
    end

  --=============================== REPL ====================================--
  elseif selected_option == "option12" then
    local cmd = "echo 'To exit the REPL enter exit()'" ..
                " && python"
    utils.run_in_terminal(cmd)
  end

end

return M
