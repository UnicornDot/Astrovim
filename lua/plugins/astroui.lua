return {
  {
    "AstroNvim/astroui",
    version = false,
    branch = "v3",
    dependencies = { "echasnovski/mini.icons" },
    ---@type AstroUIOpts
    opts = {
      -- colorscheme = "solarized-osaka",
      colorscheme = "catppuccin-mocha",
      highlights = {}
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
  -- homepage
  {
    "goolord/alpha-nvim",
    enabled = true,
    opts = function(_, opts)
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
