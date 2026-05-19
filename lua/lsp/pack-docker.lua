local astrocore = require "astrocore"

---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@type function(opts, AstroCoreOpts)
    opts = function(_, opts)
      opts.filetypes = vim.tbl_deep_extend("keep", opts.filetypes or {}, {
        filename = {
          ["docker-compose.yaml"] = "yaml",
          ["docker-compose.yml"] = "yaml"
        },
      })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = true,
    optional = true,
    opts = function(_, opts)
      -- lsp
      opts.ensure_installed = astrocore.list_insert_unique(
      opts.ensure_installed,
        {
          "docker-compose-language-service",
          "dockerfile-language-server",
          "hadolint",
          "prettierd"
        }
      )
    end,
  },
  {
    "stevearc/conform.nvim",
    lazy = true,
    optional = true,
    opts = {
      formatters_by_ft = {
        ["yaml.docker-compose"] = { "prettierd", stop_after_first = true },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    lazy = true,
    optional = true,
    opts = {
      linters_by_ft = {
        ["docker-compose"] = { "hadolint" },
      },
    }
  }
}
