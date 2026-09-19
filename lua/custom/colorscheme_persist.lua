M = {}

local file_path = vim.fn.stdpath 'data' .. 'colorscheme.lua'
local fallback_colorscheme = 'astrodark'

----------------------------------------------------------------------------------------
--Get colorsheme from File
local function get_colorscheme()
  if vim.fn.filereadable(file_path) == 0 then
    return vim.g.colors_name or fallback_colorscheme
  end

  local success, data = pcall(vim.fn.readfile, file_path)
  if success and #data > 0 then
    local colorscheme = data[1]
    if colorscheme == 'return nil' or colorscheme == '' then
      return vim.g.colors_name or fallback_colorscheme
    end
    return colorscheme
  else
    return vim.g.colors_name or fallback_colorscheme
  end
end

----------------------------------------------------------------------------------------
-- Save the current colorscheme to a file
function M.save_colorscheme(colorscheme)
  local dir = vim.fn.fnamemodify(file_path, ':h')
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end

  local success, err = pcall(vim.fn.writefile, { colorscheme }, file_path)
  if not success then
    vim.notify('Error saving colorscheme: ' .. err, vim.log.levels.ERROR)
  else
    vim.api.nvim_exec_autocmds('User', {
      pattern = 'ColorschemeUpdate',
    })
  end
end
----------------------------------------------------------------------------------------
local function apply_colorscheme(colorscheme)
  local ok, err = pcall(vim.cmd, 'colorscheme ' .. colorscheme)
  if not ok then
    vim.notify('Error applying colorscheme: ' .. err, vim.log.levels.ERROR)
    pcall(vim.cmd, 'colorscheme ' .. fallback_colorscheme)
  end
end

----------------------------------------------------------------------------------------
function M.colorscheme_picker()
  require('fzf-lua').colorschemes {
    winopts = { height = 0.5, width = 0.5 },
    actions = {
      ['default'] = function(selected)
        local colorscheme = selected[1]
        apply_colorscheme(colorscheme)
        M.save_colorscheme(colorscheme)
      end,
    },
  }
end

----------------------------------------------------------------------------------------
function M.load()
  M.current = get_colorscheme()
  -- Only apply the saved colorscheme if it's different from the current one
  if M.current ~= vim.g.colors_name then
    apply_colorscheme(M.current)
  end
end

----------------------------------------------------------------------------------------
return M
