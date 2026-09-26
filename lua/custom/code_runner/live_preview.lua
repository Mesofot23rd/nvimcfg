M = {}
M.live_preview = function()
  -- get current working directory
  local root = vim.fn.getcwd()
  local entry_files = { 'index.html', 'main.html' }

  local browser_sync_port = 3000
  local live_server_port = 8080
  local files_to_watch = '"*.html, *.css, *.js"'
  local auto_open_browser = true

  -- search the root for index.html
  -- search ${cwd}/src for index.html

  for _, target_file in ipairs(entry_files) do
    local found = vim.fs.find(target_file, { path = root, upward = false, limit = 3 })
    if #found > 0 then
      local cmd = 'live-server --browser=firefox --port=8080 ' .. found[1]
      require('custom.code_runner.utils').run_command_in_terminal(cmd)
      vim.notify(found[1], vim.log.levels.INFO, { title = '[CodeRunner]' })
      return
    end
  end
end

return M
