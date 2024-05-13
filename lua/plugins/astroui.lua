return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      colorscheme = "catppuccin",
      highlights = {
        init = function()
          local get_hlgroup = require("astroui").get_hlgroup
          -- get highlights from highlight groups
          local normal = get_hlgroup "Normal"
          local fg, bg = normal.fg, normal.bg
          local bg_alt = get_hlgroup("Visual").bg
          local green = get_hlgroup("String").fg
          local red = get_hlgroup("Error").fg
          -- return a table of highlights for telescope based on
          -- colors gotten from highlight groups
          return {
            CursorLineFold = { link = "CursorLineNr" }, -- highlight fold indicator as well as line number
            GitSignsCurrentLineBlame = { fg = get_hlgroup("NonText").fg, italic = true }, -- italicize git blame virtual text
            HighlightURL = { underline = true }, -- always underline URLs
            OctoEditable = { fg = "NONE", bg = "NONE" }, -- use treesitter for octo.nvim highlighting

            --- Telescope hl
            TelescopeBorder = { fg = bg_alt, bg = bg },
            TelescopeNormal = { bg = bg },
            TelescopePreviewBorder = { fg = bg, bg = bg },
            TelescopePreviewNormal = { bg = bg },
            TelescopePreviewTitle = { fg = bg, bg = green },
            TelescopePromptBorder = { fg = bg_alt, bg = bg },
            TelescopePromptNormal = { fg = fg, bg = bg },
            TelescopePromptPrefix = { fg = red, bg = bg },
            TelescopePromptTitle = { fg = bg, bg = red },
            TelescopeResultsBorder = { fg = bg, bg = bg },
            TelescopeResultsNormal = { bg = bg },
            TelescopeResultsTitle = { fg = bg, bg = bg },
          }
        end,
      },
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
