local astrocore = require "astrocore"
local filetypes = {
  "css",
  "eruby",
  "html",
  "htmldjango",
  "javascriptreact",
  "less",
  "pug",
  "sass",
  "scss",
  "typescriptreact",
  "vue",
}
---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = function(_, opts)
      vim.tbl_deep_extend("force", opts, {
        ---@diagnostic disable: missing-fields
        config = {
          emmet_language_server = {
            init_options = {
              ---@type boolean Dafault to `true`
              showAbbreviationSuggestions = false,
              ---@type "always" | "never" Default to `always`
              showExpandedAbbreviation = "always",
              ---@type boolean Default to `false`
              showSuggestionsAsSignppets = true,
            },
            filetypes,
          },
          html = { init_options = { provideFormatter = false } },
          cssls = {
            init_options = { provideFormatter = false },
            settings = {
              css = {
                lint = {
                  unknownAtRules = "ignore",
                },
              },
              less = {
                lint = {
                  unknownAtRules = "ignore",
                },
              },
              scss = {
                validate = false,
                lint = {
                  unknownAtRules = "ignore",
                },
              },
            },
          },
        },
      })
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "html", "css", "scss" })
      end
      vim.treesitter.language.register("scss", "less")
      vim.treesitter.language.register("scss", "postcss")
    end,
  },
  {
    "AstroNvim/astrocore",
    ---type AstroCoreOpts
    opts = {
      filetypes = {
        extension = {
          pcss = "postcss",
          postcss = "postcss",
        }
      }
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(
        opts.ensure_installed,
        { "html-lsp", "css-lsp", "cssmodules-language-server", "emmet-language-server", "prettierd" }
      )
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        html = { "prettierd", stop_after_first = true },
        css = { "prettierd", stop_after_first = true },
        scss = { "prettierd", stop_after_first = true },
        less = { "prettierd", stop_after_first = true },
        postcss = { "prettierd", stop_after_first = true },
      },
    },
  },
  {
    "echasnovski/mini.icons",
    optional = true,
    opts = {
      filetype = {
        postcss = { glyph = "󰌜", hl = "MiniIconsOrange"}
      }
    }
  }
}
