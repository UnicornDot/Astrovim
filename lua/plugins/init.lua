return {
  { "max397574/better-escape.nvim", enabled = false },
  {
    "goolord/alpha-nvim",
    enabled = true,
    opts = function(_, opts)
      local plugin_num = #vim.fn.globpath(vim.call("stdpath", "data") .. "/lazy", "*", 0, 1)
      local nvim_version = 10.0
      -- customize the dashboard header
      -- opts.section.header.val = {}
      opts.section.footer.val = {
        "",
        "                   :: Neovim loaded  " .. plugin_num .. " plugins   ",
        "---------------------------------------------------------------------",
        "                   :: Version :  [ " .. nvim_version .. " ]         ",
        "",
        [[#####################################################################]],
        [[|########## \\ 🪶:: Talk is cheap, show me you code !! // ##########|]],
        [[#####################################################################]],
      }
      local button = require("alpha.themes.dashboard").button
      opts.section.buttons.val = {
        button("LDR n  ", "󰯃  New File  "),
        button("LDR f p", "󱛊  Find Project  "),
        button("LDR f f", "  Find File  "),
        button("LDR f o", "  Recents  "),
        button("LDR f w", "󱘢  Find Word  "),
        button("LDR S f", "󰢚  Find Session  "),
        button("LDR f '", "  Bookmarks  "),
        button("LDR S l", "  Last Session  "),
      }
      return opts
    end,
  },
}
