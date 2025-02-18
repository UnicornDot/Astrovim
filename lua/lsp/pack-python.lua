local astrocore = require "astrocore"
local set_mappings = astrocore.set_mappings
local utils = require("utils")

-- print(vim.fn.stdpath "data" .. "/lazy/rust-prettifier-for-lldb/rust_prettifier_for_lldb.py")
---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = function(_, opts) 
      return vim.tbl_deep_extend("force", opts, {
        ---@diagnostic disable: missing-fields
        config = {
          basedpyright = {
            on_attach = function()
              set_mappings({
                n = {
                  ["<leader>lo"] = {
                    "<cmd>PyrightOrganizeImports<cr>",
                    desc = "Organize imports",
                  }
                }
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
                  "pyrightconfig.json",
                })(...)
            end,
            settings = {
              basedpyright = {
                analysis = {
                  typeCheckingMode = "basic",
                  autoImportCompletions = true,
                  autoSearchPaths = true,
                  diagnosticMode = "openFilesOnly",
                  useLibraryCodeForTypes = true,
                  reportMissingTypeStubs = false,
                  diagnosticSeverityOverrides = {
                    reportUnusedImport = "information",
                    reportUnusedFunction = "information",
                    reportUnusedVariable = "information",
                    reportGeneralTypeIssues = "none",
                    reportOptionalMemberAccess = "none",
                    reportOptionalSubscript = "none",
                    reportPrivateImportUsage = "none",
                  },
                },
              },
            },
          },
        },
      })
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "python", "toml", "ninja", "rst" })
      end
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(
        opts.ensure_installed,
        { "basedpyright", "black", "isort", "debugpy" }
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
        python = { "black", "isort" },
      },
    },
  }
}
