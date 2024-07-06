return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      colorscheme = "solarized-osaka",
      -- colorscheme = "catppuccin",
    },
  },
  -- icon
  {
    "onsails/lspkind.nvim",
    opts = function(_, opts)
      opts.preset = "codicons"
      opts.symbol_map = require "icons.lspkind"
      opts.before = function(_, vim_item)
        local max_width = math.floor(0.25 * vim.o.columns)
        local label = vim_item.abbr
        local truncated_label = vim.fn.strcharpart(label, 0, max_width)
        if truncated_label ~= label then vim_item.abbr = truncated_label .. "…" end
        return vim_item
      end
      return opts
    end,
  },
  -- statusline and bufferline
  {
    "rebelot/heirline.nvim",
    optional = true,
    opts = function(_, opts) opts.winbar = nil end,
  },
  -- homepage
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
  --neoscroll
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
