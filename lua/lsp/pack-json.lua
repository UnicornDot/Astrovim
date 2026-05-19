local astrocore = require "astrocore"
---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@type function(_, opts: @type AstroCoreOpts)
    opts = function(_, opts)
      opts.autocmds.auto_conceallevel_for_json = {
        {
          event = "FileType",
          desc = "Fix conceallevel for json files",
          pattern = { "json", "jsonc", "json5" },
          callback = function()
            vim.wo.spell = false
            vim.wo.conceallevel = 0
          end,
        },
      }
    end,
  },
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false,
    specs = {
      {
        "AstroNvim/astrolsp",
        ---@type function(opts: @type AstroLSPOpts)
        opts = function(_, opts)
          ---@diagnostic disable: missing-fields
          opts.config = vim.tbl_deep_extend("keep", opts.config or {}, {
            jsonls = {
              -- lazy-load schemastore when needed
              on_new_config = function(config)
                if not config.settings.json.schemas then config.settings.json.schemas = {} end
                vim.list_extend(config.settings.json.schemas, require("schemastore").json.schemas())
              end,
              settings = {
                json = {
                  format = { enable = true },
                  validate = { enable = true },
                },
              },
            },
          })
        end,
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = true,
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(
        opts.ensure_installed, { "json-lsp" }
      )
    end,
  },
}
