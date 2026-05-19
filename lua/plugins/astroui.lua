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
          Normal = { bg = "None" },
          NormalFloat = { bg = "None" },
          FloatBorder = { fg = '#7a8f98', bg = "None" },
          Float = { bg = "None" },
          WinBar = { bg = "None" },
        },
        deus = {
          SnacksPickerDir = { fg =  '#665c54' },
          SnacksPickerListCursorLine = { bg = '#4f4f64', blend = 10 },
          FzfLuaCursorLine = { bg = '#4f4f64', blend = 10 },
          BlinkCmpMenuBorder = { fg = '#7c6f64' },
          BlinkCmpGhostText = { fg = '#7c6f64' },
          LspInlayHint = { fg =  '#7c6f64' },
          LspCodeLens = { fg = '#6f6f94' },
          LazyDimmed = { fg = '#606060' },
          NonText = { fg = '#606086' },
          FoldColumn = { bg = 'None' },
          Pmenu = { bg = "None" },
        }
      }
    },
  }
}
