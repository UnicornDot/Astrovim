local astrocore = require "astrocore"
local set_mappings = astrocore.set_mappings

---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@type function
    opts = function(_, opts)
      opts.cofig = vim.tbl_deep_extend("keep", opts.config or {}, {
        taplo = {
          evenBetterToml = { schema = { catalogs = { "https://www.schemastore.org/api/json/catalog.json" } } },
          on_attach = function()
            set_mappings({
              n = {
                ["K"] = {
                  function()
                    if vim.fn.expand "%:t" == "Cargo.toml" and require("crates").popup_available() then
                      require("crates").show_popup()
                    else
                      vim.lsp.buf.hover()
                    end
                  end,
                  desc = "Show Crate Documentation",
                },
              },
            }, { buffer = true })
          end,
        },
      })
    end
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = true,
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique( opts.ensure_installed, { "taplo" })
    end,
  },
  {
    "stevearc/conform.nvim",
    lazy = true,
    optional = true,
    opts = {
      formatters_by_ft = {
        toml = { "taplo" },
      },
    },
  }
}
