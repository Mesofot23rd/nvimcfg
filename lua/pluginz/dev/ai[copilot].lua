return {
	"CopilotC-Nvim/CopilotChat.nvim",
	dependencies = {
		{ "nvim-lua/plenary.nvim", branch = "master" },
	},
	build = "make tiktoken",
	cmd = {
		"CopilotChat",
	},

	keys = {
		{
			"<leader>ai",
			function() return require("CopilotChat").toggle() end,
			desc = "Toggle (CopilotChat)",
			mode = { "n", "x" },
		},
		{
			"<leader>ax",
			function() return require("CopilotChat").reset() end,
			desc = "Clear (CopilotChat)",
			mode = { "n", "x" },
		},
		{
			"<leader>aq",
			function()
				vim.ui.input({
					prompt = "Quick Chat: ",
				}, function(input)
					if input ~= "" then require("CopilotChat").ask(input) end
				end)
			end,
			desc = "Quick Chat (CopilotChat)",
			mode = { "n", "x" },
		},
	},

	opts = function()
		local user = vim.env.USER or "User"
		user = user:sub(1, 1):upper() .. user:sub(2)

		return {
			-- See Configuration section for options
			layout = {
				-- These control the width of the aerial window.
				-- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
				-- min_width and max_width can be a list of mixed types.
				-- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
				max_width = { 40, 0.2 },
				width = nil,
				min_width = 10,
			},

			auto_insert_mode = true,
			headers = {
				user = "  " .. user .. " ",
				assistant = "  Copilot ",
				tool = "󰊳  Tool ",
			},
			window = {
				width = 0.4,
			},
		}
	end,

	config = function(_, opts)
		local chat = require "CopilotChat"

		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "copilot-chat",
			callback = function()
				vim.opt_local.relativenumber = false
				vim.opt_local.number = false
			end,
		})

		chat.setup(opts)
	end,
}
