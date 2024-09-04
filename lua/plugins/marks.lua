return {
  {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
      local maps = opts.mappings
      if maps then
        maps.n["<leader>m,"] = { "<Plug>(Marks-setnext)<CR>", desc = "Set Next Lowercase Mark" }
        maps.n["<leader>m;"] = { "<Plug>(Marks-toggle)<CR>", desc = "Toggle Mark(Set Or Cancel Mark)" }
        maps.n["<leader>m]"] = { "<Plug>(Marks-next)<CR>", desc = "Move To Next Mark" }
        maps.n["<leader>m["] = { "<Plug>(Marks-prev)<CR>", desc = "Move To Previous Mark" }
        maps.n["<leader>m:"] = { "<Plug>(Marks-preview)", desc = "Preview Mark" }
        maps.n["<leader>md"] = { "<Plug>(Marks-delete)", desc = "Delete Marks" }
      end
      opts.mappings = maps
    end
  },
  {
    "chentoast/marks.nvim",
    event = "User AstroFile",
    opts = {
      default_mappings = false,
      excluded_filetypes = {
        "qf",
        "NvimTree",
        "toggleterm",
        "TelescopePrompt",
        "alpha",
        "netrw",
        "NeoTree",
      },
    },
  },
}
