---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      -- colorscheme = "solarized-osaka",
      -- colorscheme = "catppuccin-mocha",
      -- colorscheme = "astrodark",
      colorscheme = "deus",
      -- colorscheme = "kanagawa",
      highlights = {
        init = {
          Normal = { bg = "NONE" },
          NormalFloat = { bg = "NONE" },
          FloatBorder = { fg = '#7a8f98', bg = "NONE" },
          Float = { bg = "NONE" },
          WinBar = { bg = "NONE" },
        },
        deus = {
          SnacksPickerDir = { fg =  '#665c54' },
          SnacksPickerListCursorLine = { bg = '#3c3836', fg = '#8ec07c' },
          FzfLuaCursorLine = { bg = '#3c3836', fg = '#8ec07c' },
          BlinkCmpMenuBorder = { fg = '#7c6f64' },
          BlinkCmpGhostText = { fg = '#7c6f64' },
          LspInlayHint = { fg =  '#7c6f64' },
        }
      }
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
}
