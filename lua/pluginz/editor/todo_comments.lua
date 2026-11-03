-- Highlight, list and search todo comments in your projects
-- https://github.com/folke/todo-comments.nvim
-- TODO: a todo
-- WARN: a warning
-- PERF: a performance remark
-- NOTE: a note
-- FIXME: a fixme

return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },

	keys = {
		{ "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
		{ "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
	},
	config = function()
		require("todo-comments").setup {

			signs = false, -- show icons in the signs column
		}
	end,
}
