---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      return require("astrocore").extend_tbl(opts, {
        options = {
          g = {
            ["VM_default_mappings"] = 0,
            ["Find Under"] = "<C-n>",
            ["Find Subword Under"] = "<C-n>",
            ["Add Cursor Up"] = "<C-S-k>",
            ["Add Cursor Down"] = "<C-S-j>",
            ["Select All"] = "<C-S-n>",
            ["Skip Region"] = "<C-x>",
          },
        },
      })
    end,
  },
  {
    "mg979/vim-visual-multi",
    event = "BufEnter",
  }
}
