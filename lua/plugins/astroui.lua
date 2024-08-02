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

  {
    "echasnovski/mini.icons",
    opts = function(_, opts)
      if vim.g.icons_enabled == false then opts.style = "ascii" end
    end,
    lazy = true,
    specs = {
      { "nvim-tree/nvim-web-devicons", enabled = false, optional = true },
    },
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
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
