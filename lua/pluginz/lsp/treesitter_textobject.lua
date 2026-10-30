return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = "VeryLazy",
  opts = {
    select = { lookahead = true },
    move = { set_jumps = true },
  },
  config = function(_, opts)
    require("nvim-treesitter-textobjects").setup(opts)

    local select = require("nvim-treesitter-textobjects.select")
    local move = require("nvim-treesitter-textobjects.move")

    -- Select: text objects (vaf, dif, vac, dic, etc.)
    local select_maps = {
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",
    }
    for key, query in pairs(select_maps) do
      vim.keymap.set({ "x", "o" }, key, function()
        select.select_textobject(query, "textobjects")
      end, { desc = "Select " .. query })
    end

    -- Move: next function/class (]m, ]c)
    for keys, query in pairs({
      ["]m"] = "@function.outer",
      ["]c"] = "@class.outer",
    }) do
      vim.keymap.set({ "n", "x", "o" }, keys, function()
        move.goto_next_start(query)
      end, { desc = "Next " .. query })
    end
    -- Move: previous function/class ([m, [c)
    for keys, query in pairs({
      ["[m"] = "@function.outer",
      ["[c"] = "@class.outer",
    }) do
      vim.keymap.set({ "n", "x", "o" }, keys, function()
        move.goto_previous_start(query)
      end, { desc = "Prev " .. query })
    end
  end,
}

