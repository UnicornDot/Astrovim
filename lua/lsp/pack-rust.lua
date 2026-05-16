local astrocore = require "astrocore"
local set_mappings = astrocore.set_mappings
-- vim.g.astronvim_rust_diagnostics = "bacon-ls"
local diagnostics = vim.g.astronvim_rust_diagnostics or "rust-analyzer"

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
    "cmrschwarz/rust-prettifier-for-lldb",
    lazy = true,
  },
  {
    "AstroNvim/astrolsp",
    --- @type function
    opts = function(_, opts)
      if diagnostics ~= "rust-analyzer" then
        astrocore.list_insert_unique(opts.servers, { "bacon_ls" })
      end
      return vim.tbl_deep_extend("force", opts, {
        handlers = { rust_analyzer = function() return false end }, -- disable setup of `rust_analyzer`
        ---@diagnostic disable: missing-fields
        config = {
          bacon_ls = {
            init_options = {
              updateOnSave = true,
              updateOnSaveMillis = 1000,
              updateOnChange = false,
            }
          },
          rust_analyzer = {
            on_attach = function()
              vim.api.nvim_create_autocmd({ "TermOpen", "TermClose", "BufEnter" }, {
                pattern = "term://*",
                desc = "Jump to error line",
                callback = function()
                  if vim.bo.buftype == 'terminal' then
                    local buf_name = vim.api.nvim_buf_get_name(0)
                    local cmd = string.match(buf_name, ":%s*(cargo build)$")
                    if cmd then
                      set_mappings({
                        n = {
                          ["gd"] = {
                            preview_stack_trace,
                            desc = "Jump to error line",
                          },
                        },
                      }, { buffer = true })
                    end
                  end
                end,
              })
            end,
            settings = {
              ['rust-analyzer'] = {
                cargo = {
                  allFeatures = true,
                  loadOutDirsFromCheck = true,
                  buildScripts = {
                    enable = true,
                  },
                },
                -- add clippy lints for rust if using rust-analyzer
                checkOnSave = diagnostics == "rust-analyzer",
                diagnostics = {
                  enable = diagnostics == "rust-analyzer",
                },
                procMacro = {
                  enable = true,
                  ignored = {
                    ["async-trait"] = {"async_trait"},
                    ["napi-derive"] = {"napi"},
                    ["async-recursion"] = {"async_recursion"},
                  },
                },
                files = {
                  excludeDirs = {
                    ".direnv",
                    ".git",
                    ".github",
                    ".gitlab",
                    "bin",
                    "node_modules",
                    "target",
                    "venv",
                    ".venv"
                  },
                },
                check = {
                  command = "clippy",
                  extraArgs = {
                    "--no-deps",
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
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "codelldb" })
      if diagnostics ~= "rust-analyzer" then
        astrocore.list_insert_unique(opts.ensure_installed, { "bacon" })
      end
    end,
  },
    {
    "mrcjkb/rustaceanvim",
    version = vim.fn.has "nvim-0.12" == 1 and "^9" or "^8",
    ft = "rust",
    specs = {
      {
        "AstroNvim/astrolsp",
        optional = true,
        ---@type AstroLSPOpts
        opts = {
          handlers = { rust_analyzer = false }, -- disable setup of `rust_analyzer`
        },
      },
    },
    opts = function()
      local adapter
      local codelldb_installed = pcall(function() return require("mason-registry").get_package "codelldb" end)
      local cfg = require "rustaceanvim.config"
      if codelldb_installed then
        local codelldb_path = vim.fn.exepath "codelldb"
        local this_os = vim.uv.os_uname().sysname

        local liblldb_path = vim.fn.expand "$MASON/share/lldb"
        -- The path in windows is different
        if this_os:find "Windows" then
          liblldb_path = liblldb_path .. "\\bin\\lldb.dll"
        else
          -- The liblldb extension is .so for linux and .dylib for macOS
          liblldb_path = liblldb_path .. "/lib/liblldb" .. (this_os == "Linux" and ".so" or ".dylib")
        end
        adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path)
      else
        adapter = cfg.get_codelldb_adapter()
      end

      local astrolsp_opts = vim.lsp.config["rust_analyzer"] or {}
      -- Starting from AstroNvim v6, lsp_opts returns nvim-lspconfig's
      -- root_dir(bufnr, on_dir) which is incompatible with rustaceanvim's
      -- root_dir(file_name, default_fn) signature. Drop it so rustaceanvim
      -- uses its own cargo-aware root detection.
      astrolsp_opts.root_dir = nil
      local server = {
        ---@type table | (fun(project_root:string|nil, default_settings: table|nil):table) -- The rust-analyzer settings or a function that creates them.
        settings = function(project_root, default_settings)
          local astrolsp_settings = astrolsp_opts.settings or {}

          local merge_table = require("astrocore").extend_tbl(default_settings or {}, astrolsp_settings)

          -- Merge the settings from `rustaceanvim` first.
          local ra = require "rustaceanvim.config.server"
          local settings = ra.load_rust_analyzer_settings(project_root, {
            settings_file_pattern = "rust-analyzer.json",
            default_settings = merge_table,
          })

          -- Merge the settings again from `codesettings` if available. This is
          -- the recommended way of sharing project-local settings with VSCode
          -- in newer versions of `rustaceanvim`.
          local codesettings_avail, codesettings = pcall(require, "codesettings")
          if codesettings_avail then
            settings = codesettings.with_local_settings("rust-analyzer", { settings = settings }).settings
          end
          return settings
        end,
      }
      local final_server = require("astrocore").extend_tbl(astrolsp_opts, server)
      return {
        server = final_server,
        dap = { adapter = adapter, load_rust_types = true },
        tools = { enable_clippy = false },
      }
    end,
    config = function(_, opts) vim.g.rustaceanvim = require("astrocore").extend_tbl(opts, vim.g.rustaceanvim) end,
  },
  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        cmp = { enabled = false },
        crates = {
          enabled = true,
        },
      },
      lsp = {
        enabled = true,
        on_attach = function(...) require("astrolsp").on_attach(...) end,
        actions = true,
        completion = true,
        hover = true,
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
