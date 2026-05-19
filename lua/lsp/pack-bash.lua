local astrocore = require "astrocore"

---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    opts = function(_, opts)
      opts.config = vim.tbl_deep_extend("keep", opts.config or {}, {
        bashls = {
          filetypes = { "bash", "sh", "zsh" },
        },
      })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed =
        astrocore.list_insert_unique(opts.ensure_installed, { "bash-language-server", "shfmt", "shellcheck" })
    end,
  },
  {
    "bydlw98/blink-cmp-env",
    lazy = true,
    specs = {
      {
        "saghen/blink.cmp",
        optional = true,
        opts = function(_, opts)
          return astrocore.extend_tbl(opts, {
            sources = {
              default = astrocore.list_insert_unique(opts.sources.default or {}, {"env" }),
              providers = {
                env = {
                  name = "Env",
                  module = "blink-cmp-env",
                  --- @type blink-cmp-env.Options
                  opts = {
                    item_kind = require("blink.cmp.types").CompletionItemKind.Variable,
                    show_braces = false,
                    show_documentation_window = true,
                  },
                },
              },
            }
          })
        end
      },
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts) opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "bash" }) end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        sh = { "shfmt", "shellcheck" },
        zsh = { "shfmt", "shellcheck" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
        zsh = { "shellcheck" },
      },
    },
  },
}
