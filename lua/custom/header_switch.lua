local M = {}

function M.toggle()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    return
  end

  local extension = vim.fn.fnamemodify(file, ':e'):lower()
  local filename = vim.fn.fnamemodify(file, ':t:r')

  local pairs = {
    h = { 'cpp', 'c', 'cc', 'cxx' },
    hpp = { 'cpp', 'cxx' },
    hxx = { 'cxx' },
    hh = { 'cc' },
    c = { 'h' },
    cpp = { 'h', 'hpp' },
    cc = { 'h', 'hh' },
    cxx = { 'h', 'hpp', 'hxx' },
  }

  local targets = pairs[extension]
  if not targets then
    require('custom.utils').log_warn('Not a C/C++ header or implementation file', '[HeaderSwitch]')
    return
  end

  -- Find project root using common markers, fallback to current working directory
  local root = vim.fs.root(file, { '.git', 'Makefile', 'makefile', 'CMakeLists.txt', 'meson.build', 'build.ninja', 'src/', 'build/', 'include/' })
    or vim.fn.getcwd()

  for _, ext in ipairs(targets) do
    local target_name = filename .. '.' .. ext
    -- Search for the target file starting from the root
    local found = vim.fs.find(target_name, { path = root, upward = false, limit = 3 })

    if #found > 0 then
      vim.cmd('edit ' .. found[1])
      return
    end
  end
  require('custom.utils').log_error('Corresponding header or implementation file is missing in the project', '[HeaderSwitch]')
end

return M
