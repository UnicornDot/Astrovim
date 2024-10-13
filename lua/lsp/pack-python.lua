local astrocore = require "astrocore"
local is_available = astrocore.is_available
local set_mappings = astrocore.set_mappings
local utils = require("utils")

---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      ---@diagnostic disable: missing-fields
      config = {
        basedpyright = {
          on_attach = function()
            if is_available "venv-selector.nvim" then
              set_mappings({
                n = {
                  ["<Leader>lO"] = {
                    "<cmd>VenvSelect<CR>",
                    desc = "Select VirtualEnv",
                  },
                  ["<leader>lo"] = {
                    "<cmd>PyrightOrganizeImports<CR>",
                    desc = "Organize Imports",
                  },
                },
              }, { buffer = true })
            end
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
            return util.find_git_ancestor(...)
              or util.root_pattern(unpack {
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
    },
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
    "jay-babu/mason-null-ls.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "black", "isort" })
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "python" })
      if not opts.handlers then opts.handlers = {} end
      opts.handlers.python = function() end -- make sure python doesn't get set up by mason-nvim-dap, it's being set up by nvim-dap-python
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "basedpyright" })
    end,
  },
  {
    "linux-cultist/venv-selector.nvim",
    ft = "python",
    branch = "regexp",
    enabled = vim.fn.executable("fd") == 1 or vim.fn.executable("fdfind") == 1 or vim.fn.executable("fd-find") == 1,
    dependencies = {
      "nvim-telescope/telescope.nvim",
      branch = "0.1.x",
      dependencies = {
        "nvim-lua/plenary.nvim"
      }
    },
    opts = {},
    cmd = "VenvSelect",
  },
  {
    "mfussenegger/nvim-dap-python",
    dependencies = "mfussenegger/nvim-dap",
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
}
