--------------------------------------
----- SINGLE FILE CODE RUNNER
--------------------------------------

local M = {}

local commands = {
  python = 'python3 -u "$dir/$fileName"',
  javascript = 'node "$dir/$fileName"',
  typescript = 'ts-node "$dir/$fileName"',
  lua = 'lua "$dir/$fileName"',
  ruby = 'ruby "$dir/$fileName"',
  go = 'go run "$filePath"',
  c = 'gcc "$dir/$fileName" -o "$dir/$fileNameWithoutExt" && "$dir/$fileNameWithoutExt"',
  cpp = 'g++ "$dir/$fileName" -o "$dir/$fileNameWithoutExt" && "$dir/$fileNameWithoutExt"',
  java = 'javac "$dir/$fileName" && java -cp "$dir" "$fileNameWithoutExt"',
  sh = 'bash "$dir/$fileName"',
  rust = 'rustc "$dir/$fileName" -o "$dir/$fileNameWithoutExt" && "$dir/$fileNameWithoutExt"',
  php = 'php "$dir/$fileName"',
  perl = 'perl "$dir/$fileName"',
  zig = 'zig run "$dir/$fileName"',
  kotlin = 'kotlinc "$dir/$fileName" -include-runtime -d "$dir/$fileNameWithoutExt.jar" && java -jar "$dir/$fileNameWithoutExt.jar"',
  swift = 'swift "$dir/$fileName"',
  r = 'Rscript "$dir/$fileName"',
  julia = 'julia "$dir/$fileName"',
  elixir = 'elixir "$dir/$fileName"',
  haskell = 'runhaskell "$dir/$fileName"',
  scala = 'scala "$dir/$fileName"',
  dart = 'dart run "$dir/$fileName"',
  html = 'live-server --browser=firefox --port=8080 $dir',
}

local extensions = {
  python = { 'py', 'pyw' },
  javascript = { 'js', 'mjs', 'cjs' },
  typescript = { 'ts', 'mts', 'cts' },
  lua = { 'lua' },
  ruby = { 'rb' },
  go = { 'go' },
  c = { 'c', 'h' },
  cpp = { 'cpp', 'cc', 'cxx', 'c++', 'hpp' },
  java = { 'java' },
  sh = { 'sh', 'bash', 'zsh' },
  rust = { 'rs' },
  php = { 'php' },
  perl = { 'pl', 'pm' },
  zig = { 'zig' },
  kotlin = { 'kt', 'kts' },
  swift = { 'swift' },
  r = { 'r', 'R' },
  julia = { 'jl' },
  elixir = { 'ex', 'exs' },
  haskell = { 'hs' },
  scala = { 'scala', 'sc' },
  dart = { 'dart' },
  html = { 'html' },
}

-- State
M.watch_handle = nil
M.lock = false --flag to indicate if terminal is busy or not
M.interrupting = false
M.prompt_active = false
M.coderun_dir = nil --directory to run code_runner in

-------------------------------------------------------------------------------
--- @type function : Generate command by substituting variables
-------------------------------------------------------------------------------

---@param command_template string
---@return string
function M.generate_command(command_template)
  local bufnr = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(bufnr)

  if file_path == '' then return command_template end

  local file_dir = vim.fn.fnamemodify(file_path, ':p:h')
  local file_name = vim.fn.fnamemodify(file_path, ':t')
  local file_name_without_ext = vim.fn.fnamemodify(file_path, ':t:r')
  local file_extension = vim.fn.fnamemodify(file_path, ':e')

  -- Escape special characters for shell
  local function escape(s) return s:gsub('\\', '\\\\') end

  local substitutions = {
    ['$filePath'] = escape(file_path),
    ['$fileNameWithoutExt'] = escape(file_name_without_ext),
    ['$fileName'] = escape(file_name),
    ['$fileExtension'] = escape(file_extension),
    ['$dir'] = escape(file_dir),
    ['$coderunDir'] = escape(M.coderun_dir or file_dir),
  }

  local cmd = command_template
  -- Sort by length descending to avoid partial replacements
  local keys = {}
  for k in pairs(substitutions) do
    table.insert(keys, k)
  end
  table.sort(keys, function(a, b) return #a > #b end)

  for _, key in ipairs(keys) do
    cmd = cmd:gsub('%' .. key:gsub('%$', '%$'), substitutions[key])
  end

  return cmd
end

-------------------------------------------------------------------------------
--- @type function :Get language from file extension
-------------------------------------------------------------------------------

---@param extension string
---@return string|nil
local function get_language_from_extension(extension)
  for lang, exts in pairs(extensions) do
    for _, ext in ipairs(exts) do
      if ext:lower() == extension:lower() then return lang end
    end
  end
  return nil
end

-------------------------------------------------------------------------------
--- @type function : Run code for current buffer
-------------------------------------------------------------------------------

function M.run()
  -- Fallback to language detection
  local bufnr = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(bufnr)

  if file_path == '' then
    vim.notify('No file is currently open', vim.log.levels.WARN, { title = '[CodeRunner]' })
    return
  end

  local extension = vim.fn.fnamemodify(file_path, ':e')
  local language = get_language_from_extension(extension)

  if not language then
    vim.notify('Unsupported file extension: ' .. extension, vim.log.levels.WARN, { title = '[CodeRunner]' })
    return
  end

  local command_template = commands[language]
  if not command_template then
    vim.notify('No command configured for: ' .. language, vim.log.levels.WARN, { title = '[CodeRunner]' })
    return
  end

  local cmd = M.generate_command(command_template)
  M.run_command(cmd)
end

-------------------------------------------------------------------------------
--- @type function :Execute command in terminal
-------------------------------------------------------------------------------

---@param cmd string
function M.run_command(cmd)
  if M.lock then
    vim.notify('CodeRunner is busy, please wait...', vim.log.levels.WARN, { title = '[CodeRunner]' })
    return
  end

  M.lock = true

  -- Prepend cd if we have a coderun directory
  if M.coderun_dir then
    local escaped_dir = vim.fn.shellescape(M.coderun_dir)
    cmd = 'cd ' .. escaped_dir .. ' && ' .. cmd
  end

  --[[   utils.log_debug('Executing: ' .. cmd) ]]

  -- Try multiple terminal integrations
  local executed = false

  -- Try toggleterm
  if not executed then
    local ok, _ = pcall(require, 'toggleterm')
    if ok then
      require('custom.code_runner.utils').run_command_in_terminal(cmd)
      executed = true
      vim.notify('Executed via toggleterm', vim.log.levels.INFO, { title = '[CodeRunner]' })
    end
  end

  -- Fallback to built-in terminal
  if not executed then
    vim.cmd('split | terminal ' .. cmd)
    executed = true
    vim.notify('Executed via built-in terminal', vim.log.levels.INFO, { title = '[CodeRunner]' })
  end

  -- Release lock after delay
  vim.defer_fn(function() M.lock = false end, 500)
end
-------------------------------------------------------------------------------
--- @type function : Send interrupt signal to toggleterm terminal #13
-------------------------------------------------------------------------------

function M.send_interrupt()
  if M.interrupting then return end
  M.interrupting = true

  for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf_id].buftype == 'terminal' and vim.b[buf_id].toggle_number == 13 then
      vim.notify('Sent interrupt to terminal #13', vim.log.levels.INFO, { title = '[CodeRunner]' })

      local chan = vim.b[buf_id].terminal_job_id
      if chan then
        vim.fn.chansend(chan, '\x03')
        vim.notify('Sent interrupt to terminal #13', vim.log.levels.INFO, { title = '[CodeRunner]' })
        break
      end
    end
  end

  M.interrupting = false
end

--- ### Commands for compiler.nvim
-- This plugin displays tasks for compiling/running your current project
-- based on the filetype of the file you are currently editing.

local cmd = vim.api.nvim_create_user_command

M.setup = function()
  cmd('CompilerOpen', function() require('custom.code_runner.fzf').show() end, { desc = 'Open the compiler' })

  cmd(
    'CompilerRedo',
    function() require('custom.code_runner.utils').compiler_redo() end,
    { desc = 'Redo the last selected compiler option' }
  )

  cmd('CodeRunnerRun', function() M.run() end, { desc = 'Run current file' })

  cmd('CodeRunnerInterrupt', function() M.send_interrupt() end, { desc = 'Interrupt running code' })

  ---Set up keybindings
  local opts = { noremap = true, silent = true, desc = 'CodeRunner' }

  vim.keymap.set('n', '<F5>', '<cmd>CompilerOpen<CR>')
  vim.keymap.set('n', '<F6>', '<cmd>CompilerRedo<CR>')

  vim.keymap.set(
    'n',
    '<leader>rc',
    function() require('custom.code_runner').run() end,
    vim.tbl_extend('force', opts, { desc = 'Run file' })
  )

  vim.keymap.set(
    'n',
    '<leader>rp',
    function() require('custom.code_runner.fzf').show() end,
    vim.tbl_extend('force', opts, { desc = 'Run project' })
  )

  vim.keymap.set(
    'n',
    '<leader>rh',
    function() require('custom.live_preview').live_preview() end,
    vim.tbl_extend('force', opts, { desc = 'Run in Browser' })
  )

  vim.keymap.set(
    'n',
    'F2',
    function() require('custom.code_runner').send_interrupt() end,
    vim.tbl_extend('force', opts, { desc = 'Interrupt execution' })
  )
end

return M
