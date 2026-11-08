return {
	"mfussenegger/nvim-dap",
	event = "VeryLazy",
	dependencies = {
		"rcarriga/nvim-dap-ui", --provides a clean Ui for debugging
		"nvim-neotest/nvim-nio",
		"theHamsta/nvim-dap-virtual-text", ---display the debug adapter’s information right inside your code.
		-- {
		-- 	"microsoft/vscode-js-debug",
		-- 	version = "1.x",
		-- 	build = "npm i && npm run compile vsDebugServerBundle && mv dist out",
		-- },
	},

	keys = {
		{ "<leader>b", function() require("dap").toggle_breakpoint() end },
		{ "<leader>c", function() require("dap").continue() end },
		{ "<C-'>", function() require("dap").step_over() end },
		{ "<C-;>", function() require("dap").step_into() end },
		{ "<C-:>", function() require("dap").step_out() end },
	},

	config = function()
		local dap = require "dap"
		local dapui = require "dapui"

		-- Python debug configuration
		dap.adapters.python = {
			type = "executable",
			command = "python",
			args = { "-m", "debugpy.adapter" },
		}

		dap.configurations.python = {
			{
				type = "python",
				request = "launch",
				name = "Launch file",
				program = "${file}",
				console = "integratedTerminal",
			},
		}

		-- DAPUI CONFIGURATION
		dapui.setup {
			icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
			mappings = {
				expand = { "<CR>", "<2-LeftMouse>" },
				open = "o",
				remove = "d",
				edit = "e",
				repl = "r",
				toggle = "t",
			},
			expand_lines = false, -- Disable for mobile space
			layouts = {
				{
					elements = {
						{ id = "scopes", size = 0.25 },
						{ id = "breakpoints", size = 0.25 },
						{ id = "stacks", size = 0.25 },
						{ id = "watches", size = 0.25 },
					},
					size = 40,
					position = "left",
				},
				{
					elements = {
						{ id = "repl", size = 0.5 },
						{ id = "console", size = 0.5 },
					},
					size = 10,
					position = "bottom",
				},
			},
			controls = {
				enabled = true,
				element = "repl",
				icons = {
					pause = "⏸",
					play = "▶",
					step_into = "⏎",
					step_over = "⏭",
					step_out = "⏮",
					step_back = "⏪",
					run_last = "⏯",
					terminate = "⏹",
				},
			},
			floating = {
				max_height = nil,
				max_width = nil,
				border = "single",
				mappings = {
					close = { "q", "<Esc>" },
				},
			},
			windows = { indent = 1 },
			render = {
				max_type_length = nil,
				max_value_lines = 100,
			},
		}

		-- Auto open/close dapui with proper error handling
		vim.defer_fn(function()
			if dap and dap.listeners then
				dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
				dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
				dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
			end
		end, 1000)
	end,
}
