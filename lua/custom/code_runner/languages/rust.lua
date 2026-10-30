--- Rust language actions

local M = {}

-- Frontend - options displayed on fzf-lua
M.options = {
  { text = "Build and run program", value = "option1" },
  { text = "Build program", value = "option2" },
  { text = "Run program", value = "option3" },
  { text = "Build solution", value = "option4" },
  { text = "", value = "separator" },
  { text = "Cargo build and run", value = "option5" },
  { text = "Cargo build", value = "option6" },
  { text = "Cargo run", value = "option7" },
  { text = "", value = "separator" },
  { text = "Cargo build --workspace and run", value = "option8" },
  { text = "Cargo build --workspace", value = "option9" }
}

-- Backend - terminal tasks performed on option selected
function M.action(selected_option)
  local utils = require("custom.code_runner.utils")
  local entry_point = utils.os_path(vim.fn.getcwd() .. "/main.rs", true)     -- working_directory/main.rs
  local output_dir = utils.os_path(vim.fn.getcwd() .. "/bin/", true)         -- working_directory/bin/
  local output = utils.os_path(vim.fn.getcwd() .. "/bin/program", true)      -- working_directory/bin/program
  local arguments = "-D warnings -g"                                         -- arguments can be overriden in .solution

  if selected_option == "option1" then
    local cmd = "rm -f " .. output ..  " || true" ..                                    -- clean
                " && mkdir -p " .. output_dir ..                                        -- mkdir
                " && rustc " .. entry_point .. " -o " .. output .. " " .. arguments ..  -- compile
                " && " .. output
    utils.run_in_terminal(cmd)
  elseif selected_option == "option2" then
    local cmd = "rm -f " .. output ..  " || true" ..                                    -- clean
                " && mkdir -p " .. output_dir ..                                        -- mkdir
                " && rustc " .. entry_point .. " -o " .. output .. " " .. arguments
    utils.run_in_terminal(cmd)
  elseif selected_option == "option3" then
    local cmd = output
    utils.run_in_terminal(cmd)
  elseif selected_option == "option4" then
    local entry_points
    local tasks = {}
    local executables = {}

    -- if .solution file exists in working dir
    local solution_file = utils.get_solution_file()
    if solution_file then
      local config = utils.parse_solution_file(solution_file)

      for entry, variables in pairs(config) do
        if entry == "executables" then goto continue end
        entry_point = utils.os_path(variables.entry_point)
        output = utils.os_path(variables.output)
        output_dir = utils.os_path(output:match("^(.-[/\\])[^/\\]*$"))
        arguments = variables.arguments or arguments -- optional
        local cmd = "rm -f \"" .. output ..  "\" || true" ..                                        -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                      -- mkdir
                " && rustc \"" .. entry_point .. "\" -o \"" .. output .. "\" " .. arguments
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
      entry_points = utils.find_files(vim.fn.getcwd(), "main.rs")

      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point)
        output_dir = utils.os_path(entry_point:match("^(.-[/\\])[^/\\]*$") .. "bin")           -- entry_point/bin
        output = utils.os_path(output_dir .. "/program")                                       -- entry_point/bin/program
        local cmd = "rm -f \"" .. output ..  "\" || true" ..                                       -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                     -- mkdir
                " && rustc \"" .. entry_point .. "\" -o \"" .. output .. "\" " .. arguments
        table.insert(tasks, cmd) -- store all the tasks we've created
      end

      utils.run_in_terminal(table.concat(tasks, " && "))
    end
  elseif selected_option == "option5" then
    local cmd = "cargo build " ..                                                        -- compile
                " && cargo run"
    utils.run_in_terminal(cmd)
  elseif selected_option == "option6" then
    local cmd = "cargo build "
    utils.run_in_terminal(cmd)
  elseif selected_option == "option7" then
    local cmd = "cargo run "
    utils.run_in_terminal(cmd)
  elseif selected_option == "option8" then
    local cmd = "cargo build --workspace " ..                                            -- compile
                " && cargo run"
    utils.run_in_terminal(cmd)
  elseif selected_option == "option9" then
    local cmd = "cargo build --workspace"
    utils.run_in_terminal(cmd)
  end
end

return M
