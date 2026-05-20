local astrocore = require "astrocore"
local utils = require("utils")

---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@type function
    opts = function(_, opts)
      opts.config = vim.tbl_deep_extend("keep", opts.config or {}, {
        pyrefly = {
          on_attach = function()
            astrocore.set_mappings({
              n = {
                ["<Leader>lE"] = {
                  "<cmd>VenvSelect<cr>",
                  desc = "Select virtualenv",
                },
              },
            }, { buffer = true })
          end,
          before_init = function(_, c)
            if not c.settings then c.settings = {} end
            if not c.settings.python then c.settings.python = {} end
            c.settings.python.pythonPath = vim.fn.exepath("python")
          end,
          filetypes = { "python" },
          single_file_support = true,
        },
      })
    end
  },
  {
    "mason-org/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "pyrefly" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = true,
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique( opts.ensure_installed, { "pyrefly", "ruff", "debugpy" })
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    lazy = true,
    ft = "python",
    config = function()
      if utils.is_windows() then
        require("dap-python").setup(utils.get_pkg_path("debugpy", "/venv/Scripts/python.exe"))
      else
        require("dap-python").setup(utils.get_pkg_path("debugpy", "/venv/bin/python"))
      end
    end,
  },
  {
    "nvim-neotest/neotest",
    lazy = true,
    optional = true,
    specs = { "nvim-neotest/neotest-python", lazy = true },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(opts.adapters, require "neotest-python"(require("astrocore").plugin_opts "neotest-python"))
    end,
  },
  {
    "stevearc/conform.nvim",
    lazy = true,
    optional = true,
    opts = {
      formatters_by_ft = {
        python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
      },
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    lazy = true,
    branch = "main",
    enabled = vim.fn.executable("fd") == 1 or vim.fn.executable("fdfind") == 1 or vim.fn.executable("fd-find") == 1,
    opts = {
      venvs = { "venv", ".venv", "env", ".env" },
    },
    cmd = "VenvSelect",
  }
}
