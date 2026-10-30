--- ### Extra Heirline conditions.
--
-- CONDITIONS NOT PROVIDED BY `heirline.conditions`.
-- Use `heirline.conditions` for everything else (is_active, is_git_repo,
-- has_diagnostics, lsp_attached, buffer_matches, width_percent_below, ...).

local M = {}

--- A condition function if a macro is being recorded.
---@return boolean # whether or not a macro is currently being recorded.
function M.is_macro_recording() return vim.fn.reg_recording() ~= '' end

--- A condition function if a virtual environment is activated.
---@return boolean # whether or not a virtual environment is active.
function M.has_virtual_env() return vim.env.VIRTUAL_ENV ~= nil or vim.env.CONDA_DEFAULT_ENV ~= nil end

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

return M
