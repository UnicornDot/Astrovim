--WARNING: now rust-analyzer is can't use in neovim, because this issue
-- https://github.com/rust-lang/rust-analyzer/issues/17289
-- https://github.com/williamboman/mason.nvim/issues/1741
local utils = require "astrocore"

local set_mappings = require("astrocore").set_mappings

local function preview_stack_trace()
  local current_line = vim.api.nvim_get_current_line()
  local patterns_list = {
    "--> ([^:]+):(%d+):(%d+)",
    "at ([^:]+):(%d+):(%d+)",
  }

  local function try_patterns(patterns, line)
    for _, pattern in ipairs(patterns) do
      local filepath, line_nr, column_nr = string.match(line, pattern)
      if filepath and line_nr then return filepath, tonumber(line_nr), tonumber(column_nr or 0) end
    end
    return nil, nil, nil
  end

  local filepath, line_nr, column_nr = try_patterns(patterns_list, current_line)
  if filepath then
    vim.cmd ":wincmd k"
    vim.cmd("e " .. filepath)
    vim.api.nvim_win_set_cursor(0, { line_nr, column_nr })
  end
end

---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    opts = {
      config = {
        rust_analyzer = {
          on_attach = function()
            set_mappings({
              n = {
                ["<Leader>dc"] = {
                  function() vim.cmd.RustLsp "debuggables" end,
                  { desc = "Rust Debuggables" },
                },
              },
            }, { buffer = true })
            vim.api.nvim_create_autocmd({ "TermOpen", "TermClose", "BufEnter" }, {
              pattern = "*cargo*",
              desc = "Jump to error line",
              callback = function()
                set_mappings({
                  n = {
                    ["gd"] = {
                      preview_stack_trace,
                      desc = "Jump to error line",
                    },
                  },
                }, { buffer = true })
              end,
            })
          end,
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, { "rust", "toml", "ron" })
      end
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      -- dap
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, { "codelldb" })
    end,
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = "rust",
    opts = function()
      local astrolsp_avail, astrolsp = pcall(require, "astrolsp")
      local astrolsp_opts = (astrolsp_avail and astrolsp.lsp_opts "rust_analyzer") or {}
      local server = {
        ---@type table | (fun(project_root:string|nil, default_settings: table|nil):table) -- The rust-analyzer settings or a function that creates them.
        settings = function(project_root, default_settings)
          local astrolsp_settings = astrolsp_opts.settings or {}

          local merge_table = require("astrocore").extend_tbl(default_settings or {}, astrolsp_settings)
          local ra = require "rustaceanvim.config.server"
          -- load_rust_analyzer_settings merges any found settings with the passed in default settings table and then returns that table
          return ra.load_rust_analyzer_settings(project_root, {
            settings_file_pattern = "rust-analyzer.json",
            default_settings = merge_table,
          })
        end,
      }
      local final_server = require("astrocore").extend_tbl(astrolsp_opts, server)
      return {
        server = final_server,
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            -- Add clippy lints for Rust.
            checkOnSave = true,
            procMacro = {
              enable = true,
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
          },
        },
      }
    end,
    config = function(_, opts)
      vim.g.rustaceanvim = require("astrocore").extend_tbl(opts, vim.g.rustaceanvim)
      if vim.fn.executable "rust-analyzer" == 0 then
        require("astrocore").notify(
          "**rust-analyzer** not found in PATH, please install it.\nhttps://rust-analyzer.github.io/",
          vim.log.levels.ERROR
        )
      end
    end,
  },
  {
    "Saecki/crates.nvim",
    lazy = true,
    dependencies = {
      "AstroNvim/astrocore",
      opts = {
        autocmds = {
          CmpSourceCargo = {
            {
              event = "BufRead",
              desc = "Load crates.nvim into Cargo buffers",
              pattern = "Cargo.toml",
              callback = function()
                require("cmp").setup.buffer { sources = { { name = "crates" } } }
                require "crates"
              end,
            },
          },
        },
      },
    },
    opts = {
      completion = {
        cmp = { enabled = true },
        crates = {
          enabled = true,
        },
      },
      null_ls = {
        enabled = true,
        name = "crates.nvim",
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      local rustaceanvim_avail, rustaceanvim = pcall(require, "rustaceanvim.neotest")
      if rustaceanvim_avail then table.insert(opts.adapters, rustaceanvim) end
    end,
  },
}
