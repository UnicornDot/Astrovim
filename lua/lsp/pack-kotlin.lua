local astrocore = require("astrocore")
return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "kotlin" })
      end
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "kotlin" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(
        opts.ensure_installed,
        { "kotlin-language-server", "ktlint", "ktfmt", "kotlin-debug-adapter" }
      )
    end,
  },
  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy",
    ft = "kotlin",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.kotlin = { "ktlint" }
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "codymikol/neotest-kotlin",
    },
    config = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(opts.adapters, require("neotest-kotlin")(astrocore.plugin_opts "neotest-kotlin"))
    end
  },
  {
    "stevearc/conform.nvim",
    event = "VeryLazy",
    ft = "kotlin",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      local package = "ktfmt"
      opts.formatters_by_ft.kotlin = { package }
    end
  }
}
