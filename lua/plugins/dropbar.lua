return {
  {
    "Bekaboo/dropbar.nvim",
    event = "UIEnter",
    specs = {
      {
        "rebelot/heirline.nvim",
        optional = true,
        opts = function(_, opts) opts.winbar = nil end,
      },
    },
    opts = {
      icons = {
        ui = {
          bar = {
            separator = " > ",
            extends = ".."
          },
          menu = {
            separator = " ",
            indicator = " > "
          },
        },
      },
    },
  },
}
