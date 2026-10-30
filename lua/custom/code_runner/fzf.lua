--- ### Frontend for compiler.nvim (FZF version)

local M = {}

function M.show()
  -- If working directory is home, don't open fzf.
  if vim.loop.os_homedir() == vim.loop.cwd() then
    vim.notify('You must :cd your project dir first.\nHome is not allowed as working dir.', vim.log.levels.WARN, {
      title = 'Compiler.nvim',
    })
    return
  end

  -- Dependencies
  local fzf = require 'fzf-lua'
  local utils = require 'custom.code_runner.utils'
  local utils_bau = require 'custom.code_runner.utils-bau'

  local buffer = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = buffer })

  -- POPULATE
  -- ========================================================================

  -- Programmatically require the backend for the current language.
  local language = utils.require_language(filetype)

  -- On unsupported languages, default to make.
  if not language then
    language = utils.require_language 'make' or {}
  end

  -- Also show options discovered on Makefile, Cmake... and other bau.
  if not language.bau_added then
    language.bau_added = true
    local bau_opts = utils_bau.get_bau_opts()

    -- Insert a separator for every bau.
    local last_bau_value = nil
    for _, item in ipairs(bau_opts) do
      if last_bau_value ~= item.bau then
        table.insert(language.options, { text = ' ', value = 'separator' })
        table.insert(language.options, { text = '--- ' .. item.bau:upper() .. ' ---', value = 'separator' })
        last_bau_value = item.bau
      end
      table.insert(language.options, item)
    end
  end

  -- Build entries for fzf display, including separators.
  local entries = {}
  local index_counter = 0
  for _, option in ipairs(language.options) do
    if option.value ~= 'separator' then
      index_counter = index_counter + 1
      local display_text = index_counter .. ' - ' .. option.text
      table.insert(entries, { display = display_text, value = option.value, bau = option.bau })
    else
      table.insert(entries, { display = option.text, value = 'separator' })
    end
  end

  -- RUN ACTION ON SELECTED
  -- ========================================================================

  local function on_option_selected(selection)
    if not selection then
      return
    end
    -- fzf-lua returns a table, the selected string is the first element
    local selected_text = selection[1]

    local selected_entry = nil
    for _, entry in ipairs(entries) do
      if entry.display == selected_text then
        selected_entry = entry
        break
      end
    end

    if not selected_entry or selected_entry.value == 'separator' then
      return
    end

    local bau = selected_entry.bau
    if bau then -- call the bau backend.
      local bau_mod = utils_bau.require_bau(bau)
      if bau_mod then
        bau_mod.action(selected_entry.value)
      end
      _G.compiler_redo_selection = nil
      _G.compiler_redo_bau_selection = selected_entry.value
      _G.compiler_redo_bau = bau_mod
    else -- call the language backend.
      language.action(selected_entry.value)
      _G.compiler_redo_selection = selected_entry.value
      _G.compiler_redo_filetype = filetype
      _G.compiler_redo_bau_selection = nil
      _G.compiler_redo_bau = nil
    end
  end

  -- SHOW FZF
  -- ========================================================================
  local display_list = {}
  for _, entry in ipairs(entries) do
    table.insert(display_list, entry.display)
  end

  fzf.fzf_exec(display_list, {
    prompt = 'Compiler> ',
    actions = {
      ['default'] = function(selected)
        on_option_selected(selected)
      end,
    },
    winopts = {
      height = 0.4,
      width = 0.6,
      row = 0.4,
    },
  })
end

return M
