local M = {}

local data_path = vim.fn.stdpath 'data' .. '/bg_color.txt'

local bgColors = {
  Transparent = 'NONE',
  AyuMirage_Bg = '#242835',
  GitHubDark_Bg = '#000000',
  Modest = '#0F1219',
  Zed_Bg = '#313337',
  Material_Bg = '#000000',
  Vs_Bg = '#1E1E1E',
  Astro_Bg = '#111317',
  Ayu_Bg = '#0D1016',
  OneDark_Bg = '#1E222A',
  Darwin_Bg = '#000000',
}

local groups = {
  'Normal',
  'NormalNC',
  'NormalFloat',
  'NeoTreeNormal',
  'NeoTreeNormalNC',
}

---Apply the selected background color
---@param color string|nil The color hex code or 'NONE' or nil to revert
local function apply_bg(color, notify)
  if color == nil then
    local colorscheme = vim.g.colors_name or 'astrodark'
    vim.cmd('colorscheme ' .. colorscheme)
    if notify ~= false then
      vim.notify('Reverted background color to ' .. colorscheme .. ' default', vim.log.levels.INFO)
    end
    return
  end

  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = color })
  end

  if notify ~= false then
    vim.notify('Changed background color to ' .. color, vim.log.levels.INFO)
  end
end

---Save the selected background choice to a file
---@param choice string The name of the choice (e.g., 'Astro_Bg' or 'Colorscheme')
function M.save_bg(choice)
  local f = io.open(data_path, 'w')
  if f then
    f:write(choice)
    f:close()
  end
end

---Load and apply the saved background color
function M.load_bg()
  local f = io.open(data_path, 'r')
  if f then
    local choice = f:read '*all'
    f:close()
    if choice ~= 'Colorscheme' and bgColors[choice] then
      apply_bg(bgColors[choice], false)
    end
  end
end

---Show a menu to select background color
function M.select_bg()
  local options = { 'Colorscheme' }

  for name, value in pairs(bgColors) do
    if type(value) == 'string' then
      table.insert(options, name)
    end
  end

  table.sort(options)

  require('fzf-lua').fzf_exec(options, {
    winopts = { height = 0.5, width = 0.5 },
    actions = {
      ['default'] = function(selected)
        local choice = selected[1]
        if choice == 'Colorscheme' then
          apply_bg(nil)
        else
          apply_bg(bgColors[choice])
        end
        M.save_bg(choice)
      end,
    },
  })
end

return M
