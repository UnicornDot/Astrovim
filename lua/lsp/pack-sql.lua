local sql_ft = { "sql", "mysql", "plsql", "dbt" }
--- treesitter allowed node
local allowed_filetypes_nodes = {
  go = {
    raw_string_literal = true,
    string_literal = true,
    template_string = true,
    interpreted_string_literal = true,
  },
}
local astrocore = require "astrocore"
local utils = require("utils")

local function sql_formatter_linter(name)
  local f_by_ft = {}
  for _, ft in ipairs(sql_ft) do
    f_by_ft[ft] = { name }
  end
  return f_by_ft
end

local function create_sqlfluff_config_file()
  local source_file = vim.fn.stdpath "config" .. "/.sqlfluff"
  local target_file = vim.fn.getcwd() .. "/.sqlfluff"
  utils.copy_file(source_file, target_file)
end

local function formatting()
  return { "--dialect", "polyglot"}
end

local function diagnostic()
  local system_config = vim.fn.stdpath "config" .. "/.sqlfluff"
  local project_config = vim.fn.getcwd() .. "/.sqlfluff"

  local sqlfluff = { "lint", "--format=json" }
  table.insert(sqlfluff, "--config")

  if vim.fn.filereadable(project_config) == 1 then
    table.insert(sqlfluff, project_config)
  else
    table.insert(sqlfluff, system_config)
  end
  return sqlfluff
end

local function remove_special_chars(input_str)
  local pattern = "[%+%*%?%.%^%$%(%)%[%]%%%-&%#]"
  local resultStr = input_str:gsub(pattern, "")
  return resultStr
end

---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = true,
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "sqls", "sqlfluff", "sqlfmt" })
    end,
  },
  {
    "nanotee/sqls.nvim",
    ft = sql_ft,
    lazy = true,
    specs = {
      {
        "AstroNvim/astrocore",
        optional = true,
        ---@type function
        opts = function(_, opts)
          opts.autocmds.auto_spell_for_sql = {
            {
              event = "FileType",
              desc = "create completion",
              pattern = sql_ft,
              callback = function()
                astrocore.set_mappings({
                  n = {
                    ["<Leader>lc"] = {
                      create_sqlfluff_config_file,
                      desc = "Create sqlfluff config file",
                    },
                  },
                }, { buffer = true })
              end,
            },
          }
          return vim.tbl_deep_extend("force", opts, {
            filetypes = {
              extension = {
                pg = "sql",
              },
            },
            config = {
              sqls = {
                on_attach = function(client)
                  -- Disable formatting due to bugs: https://github.com/sqls-server/sqls/issues/149
                  client.server_capabilities.documentFormattingProvider = false
                  client.server_capabilities.documentRangeFormattingProvider = false
                end,
              },
            },
          })
        end,
      }
    }
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    lazy = true,
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    dependencies =  {
      { "tpope/vim-dadbod", cmd = "DB", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = sql_ft, lazy = true },
    },
    specs = {
      "saghen/blink.cmp",
      lazy = true,
      optional = true,
      opts = function(_, opts)
        return astrocore.extend_tbl(opts, {
          sources = {
            default = astrocore.list_insert_unique(opts.sources.default, { "dadbod" }),
            providers = {
              dadbod = {
                name = "Dadbod",
                module = "vim_dadbod_completion.blink",
                score_offset = 85,
                async = true
              },
            },
          },
        })
      end
    },
    keys = {
      { "<Leader>D", "<cmd>DBUIToggle<CR>", desc = "Toggle DBUI" },
    },
    init = function()
      local data_path = vim.fn.stdpath "data"
      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_save_location = data_path .. "/dadbod_ui"
      vim.g.db_ui_show_database_icon = true
      vim.g.db_ui_tmp_query_location = data_path .. "/dadbod_ui/tmp"
      vim.g.db_ui_use_nerd_fonts = true
      vim.g.db_ui_use_nvim_notify = true
      vim.g.db_ui_winwidth = utils.size(vim.o.columns, 0.3)
      vim.g.db_ui_win_position = "right"
      vim.g.db_ui_disable_info_notifications = 1
      vim.g.db_ui_buffer_name_generator = function(opts)
        local table_name = opts.table
        if table_name and table_name ~= "" then
          return string.format("%s_%s.sql", remove_special_chars(table_name), os.time())
        else
          return string.format("console_%s.sql", os.time())
        end
      end
      -- NOTE: The default behavior of auto-execution of queries on save is disabled
      -- this is useful when you have a big query that you don't want to run every time
      -- you save the file running those queries can crash neovim to run use the
      -- default keymap: <Leader>S
      vim.g.db_ui_execute_on_save = false
    end,
  },
  {
    "KevinNitroG/blink-sql.nvim",
    lazy = true,
    specs = {
      {
        "saghen/blink.cmp",
        lazy = true,
        optional = true,
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        ---@type function
        opts = function(_, opts)
          return astrocore.extend_tbl(opts, {
            sources = {
              default = astrocore.list_insert_unique(opts.sources.default, { "sql" }),
              providers = {
                sql = {
                  name = "sql",
                  module = "blink-sql",
                  score_offset = function(ctx)
                    if vim.bo[ctx.bufnr].filetype:match("sql") then
                      return 0
                    end
                    return -5
                  end,
                  max_items = function(ctx)
                    if vim.bo[ctx.bufnr].filetype:match("sql") then
                      return 10
                    end
                    return 50
                  end,
                  should_show_items = function(ctx)
                    local filetype = vim.bo[ctx.bufnr].filetype
                    if filetype:match("sql") then
                      return true
                    end
                    local ok, node = pcall(vim.treesitter.get_node)
                    if not ok or not node then
                      return false
                    end
                    local allowed_filetype_nodes = allowed_filetypes_nodes[filetype]
                    return allowed_filetype_nodes and allowed_filetype_nodes[node:type()] or false
                  end,
                },
                lsp = {
                  fallbacks = {
                    "sql"
                  },
                },
              },
            },
          })
        end
      }
    }
  },
  {
    "stevearc/conform.nvim",
    lazy = true,
    optional = true,
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        formatters = {
          sqlfmt = {
            prepend_args = formatting()
          }
        },
        formatters_by_ft = sql_formatter_linter("sqlfmt"),
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    lazy = true,
    optional = true,
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        linters = {
          sqlfluff = {
            args = diagnostic()
          }
        },
        linters_by_ft = sql_formatter_linter("sqlfluff"),
      })
    end,
  }
}
