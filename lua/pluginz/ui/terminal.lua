return {

  'akinsho/toggleterm.nvim',
  cmd = { 'ToggleTerm' },
  config = function()
    require('toggleterm').setup {

      size = function(term)
        if term.direction == 'horizontal' then
          return 15
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        end
      end,

      persist_size = false,
      start_in_insert = true,
      insert_mappings = true, -- whether or not the open mapping applies in insert mode
      terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
      open_mapping = [[<c-\>]],
      autochdir = true,
      direction = 'vertical', --| 'horizontal' | 'tab' | 'float',
      winbar = {
        enabled = true,
        -- name_formatter = function(term) --  term: Terminal
        --   return term.name
        -- end,
      },
    }

    -- function _G.set_terminal_keymaps()
    --   local opts = { buffer = 0 }
    --   vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts) --Esc terminal mode
    --   vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts) --Esc terminal mode
    --   vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
    --   vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
    --   vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
    --   vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    --   vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts) --Close terminal
    -- end
    -- vim.cmd 'autocmd! TermOpen term://* lua set_terminal_keymaps()'

    -- vim.keymap.set({ 'n', 'i', 't' }, '<C-t>', '<Cmd>ToggleTerm<CR>')

    vim.keymap.set('n', '<leader>tv', '<Cmd>ToggleTerm direction=vertical<CR>', { desc = 'ToggleTerm Vertical' })
    vim.keymap.set(
      'n',
      '<leader>th',
      '<Cmd>ToggleTerm size=15 direction=horizontal<CR>',
      { desc = 'ToggleTerm Horizontal' }
    )
    vim.keymap.set('n', '<leader>tf', '<Cmd>ToggleTerm direction=float<CR>', { desc = 'ToggleTerm FLoat' })

    vim.keymap.set('n', '<F7>', '<Cmd>execute v:count . "ToggleTerm"<CR>', { desc = 'Toggle terminal' })
    vim.keymap.set('t', '<F7>', '<Cmd>ToggleTerm<CR>', { desc = 'Toggle terminal' })
    vim.keymap.set('i', '<F7>', '<Esc><Cmd>ToggleTerm<CR>', { desc = 'Toggle terminal' })

    vim.keymap.set('n', "<C-'>", '<Cmd>execute v:count . "ToggleTerm"<CR>', { desc = 'Toggle terminal' }) -- requires terminal that supports binding <C-'>
    vim.keymap.set('t', "<C-'>", '<Cmd>ToggleTerm<CR>', { desc = 'Toggle terminal' }) -- requires terminal that supports binding <C-'>
    vim.keymap.set('i', "<C-'>", '<Esc><Cmd>ToggleTerm<CR>', { desc = 'Toggle terminal' }) -- requires terminal that supports binding <C-'>
  end,
}
