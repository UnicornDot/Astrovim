local astrocore = require "astrocore"
local set_mappings = astrocore.set_mappings
local utils = require("utils")

---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@type function
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        ---@diagnostic disable: missing-fields
        config = {
          pyrefly = {
            on_attach = function()
              set_mappings({
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
            root_dir = function(...)
              local util = require "lspconfig.util"
              return util.root_pattern(unpack {
                "pyproject.toml",
                "setup.py",
                "setup.cfg",
                "requirements.txt",
                "Pipfile",
              })(...)
            end,
          },
        },
      })
    end
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(
        opts.ensure_installed,
        { "pyrefly", "ruff", "debugpy" }
      )
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python", -- NOTE: ft: lazy-load on filetype
    config = function()
      if vim.fn.has("win32") == 1 then
        require("dap-python").setup(utils.get_pkg_path("debugpy", "/venv/Scripts/python.exe"))
      else
        require("dap-python").setup(utils.get_pkg_path("debugpy", "/venv/bin/python"))
      end
    end,
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "nvim-neotest/neotest-python" },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(opts.adapters, require "neotest-python"(require("astrocore").plugin_opts "neotest-python"))
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        python = { "ruff" },
      },
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    branch = "main",
    enabled = vim.fn.executable("fd") == 1 or vim.fn.executable("fdfind") == 1 or vim.fn.executable("fd-find") == 1,
    opts = {
      venvs = { "venv", ".venv", "env", ".env" },
    },
    cmd = "VenvSelect",
  }
}
