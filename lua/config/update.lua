local M = {}

local config_dir = vim.fn.stdpath 'config'

local function notify(message, level)
  vim.notify(message, level, { title = 'Neovim config' })
end

local function run(args, callback)
  local output = {}
  local job = vim.fn.jobstart(vim.list_extend({ 'git', '-C', config_dir }, args), {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then vim.list_extend(output, data) end
    end,
    on_stderr = function(_, data)
      if data then vim.list_extend(output, data) end
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function() callback(exit_code, vim.tbl_filter(function(line) return line ~= '' end, output)) end)
    end,
  })

  if job <= 0 then notify('Unable to start git.', vim.log.levels.ERROR) end
end

local function confirm_update()
  vim.ui.select({ 'Update now', 'Cancel' }, {
    prompt = 'New Neovim config updates are available:',
  }, function(choice)
    if choice ~= 'Update now' then return end

    notify('Updating configuration...', vim.log.levels.INFO)
    run({ 'pull', '--ff-only' }, function(exit_code, output)
      if exit_code ~= 0 then
        notify('Config update failed: ' .. table.concat(output, ' '), vim.log.levels.ERROR)
        return
      end

      notify('Config updated. Restarting Neovim...', vim.log.levels.INFO)
      vim.defer_fn(function() vim.cmd 'restart' end, 500)
    end)
  end)
end

function M.check()
  run({ 'status', '--porcelain' }, function(exit_code, output)
    if exit_code ~= 0 then
      notify('Could not inspect the config Git repository: ' .. table.concat(output, ' '), vim.log.levels.ERROR)
      return
    end

    if #output > 0 then
      notify('Config update skipped: commit or stash local changes first.', vim.log.levels.WARN)
      return
    end

    run({ 'fetch', '--quiet' }, function(fetch_exit_code, fetch_output)
      if fetch_exit_code ~= 0 then
        notify('Could not check for config updates: ' .. table.concat(fetch_output, ' '), vim.log.levels.ERROR)
        return
      end

      run({ 'rev-list', '--count', 'HEAD..@{upstream}' }, function(count_exit_code, count_output)
        if count_exit_code ~= 0 then
          notify('Config branch has no upstream branch to update from.', vim.log.levels.ERROR)
          return
        end

        local updates = tonumber(count_output[1])
        if not updates then
          notify('Could not determine whether the config is up to date.', vim.log.levels.ERROR)
        elseif updates == 0 then
          notify('Neovim config is already up to date.', vim.log.levels.INFO)
        else
          confirm_update()
        end
      end)
    end)
  end)
end

vim.api.nvim_create_user_command('ConfigUpdate', M.check, {
  desc = 'Check for and apply Neovim config updates',
})

return M
