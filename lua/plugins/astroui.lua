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
          TabLineFill = { bg = "None", fg = "#8faa98" },
          TabLineSel = { bg = "#6f6f94" },
          TabLine = { bg = "#6f6f94" },
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
  },
  {
    "brenoprata10/nvim-highlight-colors",
    lazy = true,
    opts = {
      virtual_symbol = "󱓻",
      virtual_symbol_suffix = " ",
      enabled_named_colors = false,
      render = "virtual",
      virtual_symbol_position = "inline",
      enable_tailwind = false,
    },
  },
  {
    "levouh/tint.nvim",
    event = "User AstroFile",
    opts = {
      highlight_ignore_patterns = { "WinSeparator", "neo-tree", "Status.*"},
      tint = -40, --Darken colors, use a positive value to brighten
      saturation = 0.6 -- Saturation to preserve
    },
  },
  {
    "uga-rosa/ccc.nvim",
    event = { "User AstroFile", "InsertEnter" },
    cmd = { "CccPick", "CccConvert", "CccHighlighterEnable", "CccHighlighterDisable", "CccHighlighterToggle" },
    specs = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.n["<M-c>"] = { "<Cmd>CccHighlighterToggle<CR>", desc = "Toggle colorizer" }
          maps.n["<M-m>"] = { "<Cmd>CccConvert<CR>", desc = "Convert color" }
          maps.i["<M-p>"] = { "<Cmd>CccPick<CR>", desc = "Pick Color" }
        end,
      },
    },
    opts = {
      highlighter = {
        auto_enable = true,
        lsp = true,
      },
    },
    config = function(_, opts)
      require("ccc").setup(opts)
      if opts.highlighter and opts.highlighter.auto_enable then vim.cmd.CccHighlighterEnable() end
    end,
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "User AstroFile",
    main = "rainbow-delimiters.setup",
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    dependencies = {
      "HiPhish/rainbow-delimiters.nvim",
    },
    opts = function(_, opts)
      if not opts.scope then opts.scope = {} end
      opts.scope.show_start = true
      opts.scope.show_end = true
      opts.indent = { char = "│" }
      opts.scope.highlight = vim.tbl_get(vim.g, "rainbow_delimiters", "highlight")
        or {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        }
    end,

    config = function(plugin, opts)
      require(plugin.main).setup(opts)

      local hooks = require "ibl.hooks"
      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    end,
  },
  {
    'gen740/SmoothCursor.nvim',
    lazy = true,
    event = "User AstroFile",
    opts = {},
    config = function()
      require('smoothcursor').setup({
        cursor = "󰁕",
        fancy = {
          enable = true,
          head = { cursor = "󱓟", texthl = "SmoothCursor", linehl = nil },
        },
        disable_float_win = true,
        disabled_filetypes = { "neo-tree", "lazy"},
      })
    end
  },
  {
    "Bekaboo/dropbar.nvim",
    event = "User AstroFile",
    lazy = true,
    specs = {
      {
        "rebelot/heirline.nvim",
        optional = true,
        opts = function(_, opts) opts.winbar = nil end,
      },
    },
    opts = {
      bar = {
        enable = function(buf, win, _)
          -- Exclude terminal buffers (opencode, lazygit, etc.)
          if vim.bo[buf].bt == "terminal" then
            return false
          end
          -- Default: invalid buf/win, non-empty winbar, help => disable
          if
            not vim.api.nvim_buf_is_valid(buf)
            or not vim.api.nvim_win_is_valid(win)
            or vim.fn.win_gettype(win) ~= ""
            or vim.wo[win].winbar ~= ""
            or vim.bo[buf].ft == "help"
          then
            return false
          end
          local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
          if stat and stat.size > 1024 * 1024 then
            return false
          end
          return vim.bo[buf].ft == "markdown"
            or pcall(vim.treesitter.get_parser, buf)
            or not vim.tbl_isempty(vim.lsp.get_clients({
              bufnr = buf,
              method = "textDocument/documentSymbol",
            }))
        end,
      },
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
