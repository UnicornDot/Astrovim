--TODO: https://github.com/golang/go/issues/60903
local astrocore = require("astrocore")
local set_mapppings = astrocore.set_mappings

local function preview_stack_trace()
  local current_line = vim.api.nvim_get_current_line()
  local patterns_list = {
    "([^%s]+/[^%s]+%.go):(%d+)", -- 匹配文件路径和行号
  }
  local function try_patterns(patterns, line)
    for _, pattern in ipairs(patterns) do
      local filepath, line_nr = string.match(line, pattern)
      if filepath and line_nr then return filepath, tonumber(line_nr), 0 end
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

-- NOTE: gopls commands
-- GoTagAdd add tags
-- GOTagRm remove tags
-- GoCmt add cmt
-- GoFillStruct	auto fill struct
-- GoFillSwitch	fill switch
-- GoIfErr	Add if err
-- GoFixPlurals	change func foo(b int, a int, r int) -> func foo(b, a, r int)

---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = { filetypes = { extension = { api = "goctl" } } },
  },
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@type function
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        config = {
          gopls = {
            on_attach = function(client, _)
              vim.api.nvim_create_autocmd({ "TermOpen", "TermClose", "BufEnter" }, {
                pattern = "*",
                desc = "Jump to error line",
                callback = function()
                  local buf_name = vim.api.nvim_buf_get_name(0)
                  if vim.bo.filetype == "dap-repl" and buf_name:match("%[dap%-repl%-%d+%]") then
                    set_mapppings({
                      n = {
                        ["gd"] = {
                          preview_stack_trace,
                          desc = "Jump to error line"
                        },
                      },
                    }, { buffer = true })
                  end
                end
              })
              if not client.server_capabilities.semanticTokensProvider then
                local semantic = client.config.capabilities.textDocument.semanticTokens
                client.server_capabilities.semanticTokensProvider = {
                  full = true,
                  legend = {
                    tokenTypes = semantic.tokenTypes,
                    tokenModifiers = semantic.tokenModifiers,
                  },
                  range = true,
                }
              end
            end,
            settings = {
              gopls = {
                analyses = {
                  ST1003 = true,
                  fieldalignment = false,
                  fillreturns = true,
                  nilness = true,
                  nonewvars = true,
                  shadow = true,
                  undeclaredname = true,
                  unreachable = true,
                  unusedparams = true,
                  unusedwrite = true,
                  useany = true,
                },
                codelenses = {
                  generate = true, -- show the `go generate` lens.
                  regenerate_cgo = true,
                  test = true,
                  tidy = true,
                  upgrade_dependency = true,
                  vendor = true,
                },
                hints = {
                  assignVariableTypes = true,
                  compositeLiteralFields = true,
                  compositeLiteralTypes = true,
                  constantValues = true,
                  functionTypeParameters = true,
                  parameterNames = true,
                  rangeVariableTypes = true,
                },
                buildFlags = { "-tags", "integration" },
                completeUnimported = true,
                diagnosticsDelay = "500ms",
                gofumpt = true,
                matcher = "Fuzzy",
                semanticTokens = true,
                staticcheck = true,
                symbolMatcher = "fuzzy",
                usePlaceholders = true,
              },
            },
          },
        },
      })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      if vim.fn.executable "go" == 1 then
        opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, {
          "delve",
          "gopls",
          "gomodifytags",
          "gotests",
          "iferr",
          "impl",
          "goimports",
        })
      end
    end,
  },
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = {
      "mfussenegger/nvim-dap",
      {
        "jay-babu/mason-nvim-dap.nvim",
        optional = true,
        opts = function(_, opts)
          opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "delve" })
        end,
      },
    },
    opts = {}
  },
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    enabled = vim.fn.executable "go" == 1,
    build = function()
      if not require("lazy.core.config").spec.plugins["mason.nvim"] then
        vim.print "Installing go dependencies..."
        vim.cmd.GoInstallDeps()
      end
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "fredrikaverpil/neotest-golang" },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(opts.adapters, require "neotest-golang"(require("astrocore").plugin_opts "neotest-golang"))
    end,
  },
  {
    "chaozwn/goctl.nvim",
    ft = "goctl",
    enabled = vim.fn.executable "goctl" == 1,
    opts = function()
      local group = vim.api.nvim_create_augroup("GoctlAutocmd", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "goctl",
        callback = function()
          -- set up format keymap
          vim.keymap.set(
            "n",
            "<Leader>lf",
            "<Cmd>GoctlApiFormat<CR>",
            { silent = true, noremap = true, buffer = true, desc = "Format Buffer" }
          )
        end,
      })
    end,
  },
  {
    "strevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        go = { "goimports", lsp_format = "last" },
      }
    }
  },
  {
    "nvim-mini/mini.icons",
    optional = true,
    opts = {
      file = {
        [".go-version"] = { glyph = "", hl = "MiniIconsBlue" },
      },
      filetype = {
        gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
      },
    },
  }
}
