--- ### Heirline conditions.
--
-- DESCRIPTION:
-- When a condition is used on a component,
-- the component will only enabled when the condition returns true.

local M = {}

local env = require 'custom.statusline_components.env'

--- A condition function if the window is currently active.
---@return boolean # whether or not the window is currently active.
function M.is_active() return vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin) end

--- A condition function if the buffer filetype,buftype,bufname match a pattern.
---@param patterns table the table of patterns to match.
---@param bufnr number of the buffer to match (Default: 0 [current]).
---@return boolean # whether or not it matches.
function M.buffer_matches(patterns, bufnr)
  for kind, pattern_list in pairs(patterns) do
    if env.buf_matchers[kind](pattern_list, bufnr) then return true end
  end
  return false
end

--- A condition function if a macro is being recorded.
---@return boolean # whether or not a macro is currently being recorded.
function M.is_macro_recording() return vim.fn.reg_recording() ~= '' end

--- A condition function if search is visible.
---@return boolean # whether or not searching is currently visible.
function M.is_hlsearch() return vim.v.hlsearch ~= 0 end

--- A condition function if showcmdloc is set to statusline.
---@return boolean # whether or not statusline showcmd is enabled.
function M.is_statusline_showcmd() return vim.opt.showcmdloc:get() == 'statusline' end

--- A condition function if the current file is in a git repo.
---@param bufnr table|integer a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer.
---@return boolean # whether or not the current file is in a git repo.
function M.is_git_repo(bufnr)
  if type(bufnr) == 'table' then bufnr = bufnr.bufnr end
  local buf = bufnr or 0
  return vim.b[buf].gitsigns_head or vim.b[buf].gitsigns_status_dict
end

--- A condition function if there are any git changes.
---@param bufnr table|integer a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer.
---@return boolean # whether or not there are any git changes.
function M.git_changed(bufnr)
  if type(bufnr) == 'table' then bufnr = bufnr.bufnr end
  local buf = bufnr or 0

  local git_status, n_changes, is_changed
  local gitsigns = vim.b[buf].gitsigns_status_dict

  if gitsigns then
    git_status = gitsigns
    n_changes = (git_status.added or 0) + (git_status.removed or 0) + (git_status.changed or 0)
  end

  is_changed = n_changes and n_changes > 0
  return is_changed
end

--- A condition function if the current buffer is modified.
function M.file_modified(bufnr)
  if type(bufnr) == 'table' then bufnr = bufnr.bufnr end
  return vim.bo[bufnr or 0].modified
end

--- A condition function if the current buffer is read only.
function M.file_read_only(bufnr)
  if type(bufnr) == 'table' then bufnr = bufnr.bufnr end
  local buf = bufnr or 0
  return not vim.bo[buf].modifiable or vim.bo[buf].readonly
end

--- A condition function if the current file has any diagnostics.
function M.has_diagnostics(bufnr)
  if type(bufnr) == 'table' then bufnr = bufnr.bufnr end
  local buf = bufnr or 0
  local diagnostics = vim.diagnostic.get(buf)
  return diagnostics and #diagnostics > 0
end

--- A condition function if there is a defined filetype.
function M.has_filetype(bufnr)
  if type(bufnr) == 'table' then bufnr = bufnr.bufnr end
  local buf = bufnr or 0
  return vim.bo[buf].filetype and vim.bo[buf].filetype ~= ''
end

--- A condition function if a virtual environment is activated
function M.has_virtual_env() return vim.env.VIRTUAL_ENV ~= nil or vim.env.CONDA_DEFAULT_ENV ~= nil end

--- A condition function if LSP is attached.
function M.lsp_attached(bufnr)
  if type(bufnr) == 'table' then bufnr = bufnr.bufnr end
  return next(vim.lsp.get_clients { bufnr = bufnr or 0 }) ~= nil
end

--- A condition function if the window width is below a limit.
function M.width_below(limit) return vim.api.nvim_win_get_width(0) < limit end

return M
