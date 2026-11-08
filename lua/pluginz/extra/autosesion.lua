-- Session management. This saves your session in the background,
-- keeping track of open buffers, window arrangement, and more.
-- You can restore sessions when returning through the dashboard.

-- Snapshot the config's 'sessionoptions' (set in base/options.lua). A session
-- restored from an older config can overwrite it with a broader value containing
-- "options"/"globals", which would make Neovim persist global UI options such
-- as `laststatus=3` into the next session.
local sessionoptions = vim.o.sessionoptions

return {
	{
		"rmagatti/auto-session",
		lazy = false,
		opts = {
			log_level = "error",
			suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
			-- show_auto_restore_notif = true,
			close_filetypes_on_save = { "checkhealth" },

			-- Only save meaningful buffers
			bypass_save_file_types = {
				"neo-tree",
				"NvimTree",
				"toggleterm",
				"nvterm",
				"help",
				"qf",
				"Trouble",
				"lazy",
				"mason",
				"alpha",
				"dashboard",
				"starter",
				"noice",
				"notify",
			},

			pre_save_cmds = {
				function()
					-- Never persist global options/variables ("options"/"globals") in
					-- sessions; they can carry UI state like `laststatus=3` into future
					-- restores. Only the flags from base/options.lua are allowed.
					vim.o.sessionoptions = sessionoptions
				end,
				function()
					-- Close special UI buffers before saving
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						local buf = vim.api.nvim_win_get_buf(win)
						if vim.api.nvim_buf_is_valid(buf) then
							local ft = vim.bo[buf].filetype
							local bt = vim.bo[buf].buftype
							if ft == "neo-tree" or bt == "terminal" or bt == "help" or bt == "nofile" or bt == "quickfix" then
								pcall(vim.api.nvim_win_close, win, true)
							end
						end
					end
					-- Also close neo-tree specifically
					-- pcall(vim.cmd, 'Neotree close')
				end,
			},

			post_restore_cmds = {
				function()
					-- Old sessions may restore a broader 'sessionoptions'; put ours back
					-- so the next save stays clean.
					vim.o.sessionoptions = sessionoptions
				end,
				function()
					-- Clear neo-tree if present
					-- pcall(vim.cmd, "Neotree close") --Neoetree is configured to clear after session restore

					-- Ensure we don't land on terminal/empty/special buffers
					local cur = vim.api.nvim_get_current_buf()
					if vim.api.nvim_buf_is_valid(cur) then
						local ft = vim.bo[cur].filetype
						local bt = vim.bo[cur].buftype
						local name = vim.api.nvim_buf_get_name(cur)
						if
							ft == "neo-tree"
							or bt == "terminal"
							or bt == "help"
							or bt == "nofile"
							or bt == "quickfix"
							or name == ""
						then
							-- Try to find a normal file buffer
							for _, buf in ipairs(vim.api.nvim_list_bufs()) do
								if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
									local bft = vim.bo[buf].filetype
									local bbt = vim.bo[buf].buftype
									local bname = vim.api.nvim_buf_get_name(buf)
									if bbt == "" and bft ~= "neo-tree" and bname ~= "" then
										pcall(vim.api.nvim_set_current_buf, buf)
										break
									end
								end
							end
						end
					end
				end,
			},
		},
	},
}
