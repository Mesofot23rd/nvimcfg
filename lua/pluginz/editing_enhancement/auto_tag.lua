return {
	--autopair for html tags.
	"windwp/nvim-ts-autotag",
	event = { "InsertEnter" },
	-- ft = { "html", "xml" },
	config = function()
		require("nvim-ts-autotag").setup {
			opts = {
				enable_close = true, -- Auto close tags
				enable_rename = true, -- Auto rename pairs of tags
				enable_close_on_slash = true, -- Auto close on trailing </
				filetypes = {
					"html",
					"javascript",
					"typescript",
					"javascriptreact",
					"typescriptreact",
					"svelte",
					"vue",
					"tsx",
					"jsx",
					"rescript",
					"xml",
					"php",
					"markdown",
					"astro",
					"glimmer",
					"handlebars",
					"hbs",
				},
			},
		}
	end,
}
