local astrocore = require "astrocore"
return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    ---@diagnostic disable-next-line: assign-type-mismatch
    opts = function(_, opts)
      astrocore.extend_tbl(opts, {
        ---@diagnostic disable: missing-fields
        config = {
          qmlls = {
            root_dir = require("lspconfig.util").root_pattern(
              "shell.qml",
              ".qmlls.ini",
              ".git"
            ),
          }
        },
      })
      vim.lsp.enable("qmlls")
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "qmlls" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts) opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "qmlls" }) end,
  }
}
