local astrocore = require "astrocore"

---@type LazySpec
return {
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    specs = {
      {
        "AstroNvim/astrolsp",
        ---@type function
        opts = function(_, opts)
          vim.tbl_deep_extend("force", opts, {
            ---@diagnostic disable: missing-fields
            config = {
              yamlls = {
                on_new_config = function(config)
                  config.settings.yaml.schemas = vim.tbl_deep_extend(
                    "force",
                    config.settings.yaml.schemas or {},
                    require("schemastore").yaml.schemas()
                  )
                end,
                settings = { yaml = { schemaStore = { enable = false, url = "" } } },
              },
            },
          })
        end
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts) opts.ensure_installed = astrocore.list_insert_unique(
      opts.ensure_installed,
      { "yaml-language-server", "prettierd" })
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        yaml = { "prettierd", stop_after_first = true },
      },
    },
  }
}
