return {
  'jake-stewart/multicursor.nvim',

   enabled=false,
  -- keys = {
  --   -- Add or skip cursor above/below the main cursor.
  --   { mode = { 'n', 'x' }, '<M-<up>>', function() require('multicursor-nvim').lineAddCursor(-1) end },
  --   { mode = { 'n', 'x' }, '<M-down>', function() require('multicursor-nvim').lineAddCursor(1) end },
  --   { mode = { 'n', 'x' }, '<leader><up>', function() require('multicursor-nvim').lineSkipCursor(-1) end },
  --   { mode = { 'n', 'x' }, '<leader><down>', function() require('multicursor-nvim').lineSkipCursor(1) end },

  --   -- Add or skip adding a new cursor by matching word/selection
  --   { mode = { 'n', 'x' }, '<leader>n', function() require('multicursor-nvim').matchAddCursor(1) end },
  --   { mode = { 'n', 'x' }, '<leader>s', function() require('multicursor-nvim').matchSkipCursor(1) end },
  --   { mode = { 'n', 'x' }, '<leader>N', function() require('multicursor-nvim').matchAddCursor(-1) end },
  --   { mode = { 'n', 'x' }, '<leader>S', function() require('multicursor-nvim').matchSkipCursor(-1) end },

  --   -- Add and remove cursors with control + left click.
  --   { '<c-leftmouse>', require('multicursor-nvim').handleMouse },
  --   { '<c-leftdrag>', require('multicursor-nvim').handleMouseDrag },
  --   { '<c-leftrelease>', require('multicursor-nvim').handleMouseRelease },

  --   -- Disable and enable cursors.
  --   { mode = { 'n', 'x' }, '<M-c>', require('multicursor-nvim').toggleCursor },
  -- },

  ----------------------------------------------------------------------------------------------------------------
  config = function()
     local mc = require 'multicursor-nvim'
    mc.setup()

    local set = vim.keymap.set

    -- Add or skip cursor above/below the main cursor.
    set({ 'n', 'x' }, '<M-Up>', function() mc.lineAddCursor(-1) end)
    set({ 'n', 'x' }, '<M-Down>', function() mc.lineAddCursor(1) end)
    set({ 'n', 'x' }, '<M-S-Up>', function() mc.lineSkipCursor(-1) end)
    set({ 'n', 'x' }, '<M-S-Down>', function() mc.lineSkipCursor(1) end)

    -- Add or skip adding a new cursor by matching word/selection
    -- set({ 'n', 'x' }, '<leader>n', function() mc.matchAddCursor(1) end)
    -- set({ 'n', 'x' }, '<leader>s', function() mc.matchSkipCursor(1) end)
    -- set({ 'n', 'x' }, '<leader>N', function() mc.matchAddCursor(-1) end)
    -- set({ 'n', 'x' }, '<leader>S', function() mc.matchSkipCursor(-1) end)

    -- Add and remove cursors with control + left click.
    set('n', '<c-leftmouse>', mc.handleMouse)
    set('n', '<c-leftdrag>', mc.handleMouseDrag)
    set('n', '<c-leftrelease>', mc.handleMouseRelease)

    -- Disable and enable cursors.
    set({ 'n', 'x' }, '<C-q>', mc.toggleCursor)

    -- Mappings defined in a keymap layer only apply when there are
    -- multiple cursors. This lets you have overlapping mappings.
    mc.addKeymapLayer(function(layerSet)
      -- Select a different cursor as the main one.
      layerSet({ 'n', 'x' }, '<left>', mc.prevCursor)
      layerSet({ 'n', 'x' }, '<right>', mc.nextCursor)

      -- Delete the main cursor.
      layerSet({ 'n', 'x' }, '<leader>x', mc.deleteCursor)

      -- Enable and clear cursors using escape.
      layerSet('n', '<esc>', function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)

    -- Customize how cursors look.
    local hl = vim.api.nvim_set_hl
    hl(0, 'MultiCursorCursor', { reverse = true })
    hl(0, 'MultiCursorVisual', { link = 'Visual' })
    hl(0, 'MultiCursorSign', { link = 'SignColumn' })
    hl(0, 'MultiCursorMatchPreview', { link = 'Search' })
    hl(0, 'MultiCursorDisabledCursor', { reverse = true })
    hl(0, 'MultiCursorDisabledVisual', { link = 'Visual' })
    hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn' })
  end,
}
