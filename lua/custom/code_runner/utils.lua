--- ### Utils for compiler.nvim

local M = {}

-------------------------------------------------------------------------------
--- @type function : Run a command in a Terminal vertical split.
-------------------------------------------------------------------------------

---Reuses the same terminal if already open.
---On success, auto-closes after 20 seconds.
---On failure, maps `q` to manually close.

---@param cmd string The command to run.
function M.run_in_terminal(cmd)
  -- cmd[command ]
  -- count
  -- size
  -- dir
  -- direction
  -- name
  -- go_back _ whether or not to return to original window
  -- open _ whether or not to open terminal window

  require('toggleterm').exec(cmd, 13, vim.o.columns * 0.4, nil, 'vertical', nil, true)
end

-------------------------------------------------------------------------------
--- @type function :
-------------------------------------------------------------------------------

function M.compiler_redo()
  local current_filetype = vim.bo.filetype

  -- If the user didn't select an option yet, send a notification.
  if _G.compiler_redo_selection == nil and _G.compiler_redo_bau_selection == nil then
    vim.notify(
      'Open the compiler and select an option before doing redo.',
      vim.log.levels.INFO,
      { title = 'Compiler.nvim' }
    )
    return
  end
  if _G.compiler_redo_filetype then
    -- If filetype is not the same as when the option was selected, send a notification.
    if _G.compiler_redo_filetype ~= current_filetype then
      vim.notify(
        'You are on a different language now. Open the compiler and select an option before doing redo.',
        vim.log.levels.INFO,
        { title = 'Compiler.nvim' }
      )
      return
    end
  end
  -- Redo
  local bau = _G.compiler_redo_bau
  if bau then
    local bau_selection = _G.compiler_redo_bau_selection
    if bau_selection then bau.action(bau_selection) end
  else
    local language = require('custom.code_runner.utils').require_language(current_filetype)
    if not language then language = require('custom.code_runner.utils').require_language 'make' end
    language.action(_G.compiler_redo_selection)
  end
end

-------------------------------------------------------------------------------
--- @type function : ---Recursively searches for files with the given name
--- in all directories under start_dir.
-------------------------------------------------------------------------------

--- Use this function instead of `find_files_to_compile()` if you need
--- to operate the paths after calling the function.
---@param start_dir string A dir path string.
---@param file_name string A file path string.
---@param surround boolean|nil If true, surround every returned path by "". False by default.
---@return table files If any, a tables of files. Otherwise, a Empty table.
function M.find_files(start_dir, file_name, surround)
  local files = {}

  -- Create the find command with appropriate flags for recursive searching
  local find_command
  if string.sub(package.config, 1, 1) == '\\' then -- Windows
    find_command = string.format(
      'powershell.exe -Command "Get-ChildItem -Path \\"%s\\" -Recurse -Filter \\"%s\\" -File -Exclude \\".git\\" -ErrorAction SilentlyContinue"',
      start_dir,
      file_name
    )
  else -- UNIX-like systems
    find_command = string.format(
      'find "%s" -type d -name ".git" -prune -o -type f -name "%s" -print 2>/dev/null',
      start_dir,
      file_name
    )
  end

  -- Execute the find command and capture the output
  local pipe = io.popen(find_command, 'r')
  if pipe then
    for file_path in pipe:lines() do
      if surround then
        table.insert(files, '"' .. file_path .. '"')
      else
        table.insert(files, file_path)
      end
      --print("Found file:", file_path)
    end
    pipe:close()
  end

  return files
end

-------------------------------------------------------------------------------
--- @type function :
-------------------------------------------------------------------------------

---Search recursively, starting by the directory
---of the entry_point file. Return files matching the pattern.
---
---The paths returned are surrounded by "".
---@param entry_point string Entry point file of the program.
---@param pattern string File extension to search.
---@return string files_as_string Files separated by a space.
---@usage find_files_to_compile("/path/to/main.c", "*.c")
function M.find_files_to_compile(entry_point, pattern)
  local entry_point_dir = vim.fn.fnamemodify(entry_point, ':h')
  local files = M.find_files(entry_point_dir, pattern, true)
  local files_as_string = table.concat(files, ' ')

  return files_as_string
end

-------------------------------------------------------------------------------
--- @type function :
-------------------------------------------------------------------------------

---Parse the solution file and extract variables.
---@param file_path string Path of the solution file to read.
---@return table config A table like { {entry_point, ouptput, ..} .. }
---The last table will only contain the solution executables like:
---{ "/path/to/executable", ... }
function M.parse_solution_file(file_path)
  local file = assert(io.open(file_path, 'r'))
  local config = {}
  local executables = {}
  local current_entry = nil

  for line in file:lines() do
    if not (line:match '^%s*#' or line:match '^%s*$') then
      local entry = line:match '%[([^%]]+)%]'
      if entry then
        current_entry = entry
        config[current_entry] = {}
      else
        local key, value = line:match '([^=]+)%s-=%s-(.+)'
        if key and value and current_entry then
          key = vim.trim(key)
          value = value:gsub('^%s*', ''):gsub(' *#.*', ''):gsub('^[\'"](.-)[\'"]$', '%1') -- Remove inline comments and surrounding quotes

          if key == 'entry_point' and value:find '^%$current_buffer' then
            value = string.gsub( -- Substitute $current_buffer by actual path
              value,
              '$current_buffer',
              vim.api.nvim_buf_get_name(0)
            )
          end

          if string.find(key, 'executable') then
            table.insert(executables, value)
          else
            config[current_entry][key] = value
          end
        end
      end
    end
  end

  file:close()
  config['executables'] = executables

  for key, value in pairs(config) do
    if type(value) == 'table' and next(value) == nil then config[key] = nil end
  end

  return config
end

-------------------------------------------------------------------------------
--- @type function :
-------------------------------------------------------------------------------

---Programatically require the backend for the current language.
---@return table|nil language The language backend.
-- If ./languages/<filetype>.lua doesn't exist, return nil.
function M.require_language(filetype)
  local local_path = debug.getinfo(1, 'S').source:sub(2)
  local local_path_dir = local_path:match '(.*[/\\])'
  local module_file_path = M.os_path(local_path_dir .. 'languages/' .. filetype .. '.lua')
  local success, language = pcall(dofile, module_file_path)

  if success then
    return language
  else
    return nil
  end
end

-------------------------------------------------------------------------------
--- @type function :
-------------------------------------------------------------------------------

---Function that returns true if a file exists in physical storage
---@return boolean|nil exists true or false
function M.file_exists(filename)
  local stat = vim.loop.fs_stat(filename)
  return stat and stat.type == 'file'
end

---Function that returns the path of the .solution file if exists in the current
---working directory root, or nil otherwise.
---@return string|nil path Path of the .solution file if exists in the current
---working directory root, or nil otherwise.
function M.get_solution_file()
  if M.file_exists '.solution.toml' then
    return M.os_path(vim.fn.getcwd() .. '/.solution.toml')
  elseif M.file_exists '.solution' then
    return M.os_path(vim.fn.getcwd() .. '/.solution')
  else
    return nil
  end
end

-------------------------------------------------------------------------------
--- @type function :
-------------------------------------------------------------------------------

---Given a string, convert 'slash' to 'inverted slash' if on windows, and vice versa on UNIX.
---Then return the resulting string surrounded by "".

---This way the shell will be able to detect spaces in the path.
---@param path string A path string.
---@param surround boolean|nil If true, surround path by "". False by default.
---@return string|nil,nil path A path string formatted for the current OS.
function M.os_path(path, surround)
  if path == nil then return nil end
  if surround == nil then surround = false end

  local separator = string.sub(package.config, 1, 1)

  if surround then path = '"' .. path .. '"' end

  return string.gsub(path, '[/\\]', separator)
end

-------------------------------------------------------------------------------
--- @type function :
-------------------------------------------------------------------------------

---Returns the tests dir + a path_to_append at the end.
---@param path_to_append string A subdirectory to append to he returned dir.
---@return string path tests dir + path_to_append. Supports windows and unix.
function M.get_tests_dir(path_to_append)
  local plugin_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h:h')
  return M.os_path(plugin_dir .. '/tests/' .. path_to_append)
end

return M
