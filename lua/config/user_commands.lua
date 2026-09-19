---------------------------------------------------------------------------------
-- CHANGE BACKGROUND COLOR
vim.api.nvim_create_user_command('Bg', function()
  require('custom.bg_change').select_bg()
end, { desc = 'Select Background Color' })

---------------------------------------------------------------------------------
vim.api.nvim_create_user_command('Cp', function()
  require('custom.colorscheme_persist').colorscheme_picker()
end, { desc = 'Select ColorScheme' })
