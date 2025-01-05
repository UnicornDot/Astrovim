---@type LazySpec
return {
  "numToStr/Comment.nvim",
  config = function()
    local ft = require "Comment.ft"
    ft.thrift = { "//%s", "/*%s*/" }
    ft.goctl = { "//%s", "/*%s*/" }
  end,
  dependencies = {
    {
      "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
      opt = function(_, opts)
        local maps = require("astrocore").empty_map_table()
        maps.n["<C-/>"] = opts.mappings.n["<leader>/"]
        maps.x["<C-/>"] = opts.mappings.n["<leader>/"]
        maps.n["<leader>/"] = false
        maps.x["<leader>/"] = false
        opts.mappings = vim.tbl_deep_extend("force", opts.mappings, maps)
      end
    },
  }
}
