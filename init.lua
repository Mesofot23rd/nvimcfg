--
-- ███╗   ██║███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--------------------------------------------------------------------------------
-- NeoVim Configuration Entry Point
--------------------------------------------------------------------------------

local function load_source(source)
	local status_ok, error = pcall(require, source)
	if not status_ok then
		vim.api.nvim_echo({ { "Failed to load " .. source .. "\n\n" .. error } }, true, { err = true })
	end
end

local function load_sources(source_files)
	vim.loader.enable()
	for _, source in ipairs(source_files) do
		load_source(source)
	end
end

vim.loader.enable()

-- Load modules
load_sources {
	"base.options", -- Basic neovim configuration
	"base.auto_commands", -- Event based settings and actions
	"base.mappings", -- Global key mappings (plugin specific mappings are within plugin configuration)
	"base.diagnostics", -- Loads diagnostics related settings
	"base.lazy_setup", -- Lazy bootstrap and configuration (handles conditional plugin loading)

	"custom.statusline", -- Custom native statusline, winbar, tabline & statuscolumn
	-- 'custom.code_runner'
}
