return {
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = require("astrocore").empty_map_table()
      maps.n["<C-/>"] = opts.mappings.n["<leader>/"]
      maps.x["<C-/>"] = opts.mappings.n["<leader>/"]
      maps.n["<leader>/"] = false
      maps.x["<leader>/"] = false
    end
  },
  {
    "numToStr/Comment.nvim",
    opts = function()
      local ft = require "Comment.ft"
      ft.thrift = { "//%s", "/*%s*/" }
      ft.goctl = { "//%s", "/*%s*/" }
    end,
  }
}
