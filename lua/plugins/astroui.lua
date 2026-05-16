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
  }
}
