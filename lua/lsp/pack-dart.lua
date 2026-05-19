local astrocore = require("astrocore")
return {
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@type function
    opts = function(_, opts)
      opts.handlers = vim.tbl_deep_extend("keep", opts.handlers or {}, {
          dartls = function() return false end
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      -- HACK: Disables the select treesitter textobjects because the Dart treesitter parser is very inefficient. Hopefully this gets fixed and this block can be removed in the future.
      -- Reference: https://github.com/AstroNvim/AstroNvim/issues/2707
      local select = vim.tbl_get(opts, "textobjects", "select")
      if select then select.disable = astrocore.list_insert_unique(select.disable, { "dart" }) end
    end,
  },
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = "dart",
    lazy = true,
    opts = function(_, opts)
      opts.lsp = vim.lsp.config["dartls"] or {}
      opts.debugger = { enabled = true }
    end,
    specs = {
      "nvim-lua/plenary.nvim", lazy = true
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    lazy = true,
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "dart" })
    end
  }
}
