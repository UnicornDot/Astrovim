local astrocore = require("astrocore")
local utils = require("utils")

local function create_buf_config_file()
  local source_file = vim.fn.stdpath "config" .. "/buf.yaml"
  local target_file = vim.fn.getcwd() .. "/buf.yaml"
  local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
  local cmd = is_windows
      and string.format("copy %s %s", vim.fn.shellescape(source_file, true), vim.fn.shellescape(target_file, true))
    or string.format("cp %s %s", vim.fn.shellescape(source_file), vim.fn.shellescape(target_file))
  os.execute(cmd)
end

local function create_buf_gen_config_file()
  local source_file = vim.fn.stdpath("config") .. "/buf.gen.yaml"
  local target_file = vim.fn.getcwd() .. "/buf.gen.yaml"
  local is_windows = vim.uv.os_uname().sysname == "Windows_NT"
  local cmd = is_windows
      and string.format("copy %s %s", vim.fn.shellescape(source_file, true), vim.fn.shellescape(target_file, true))
      or string.format("cp %s %s", vim.fn.shellescape(source_file), vim.fn.shellescape(target_file))
  os.execute(cmd)
end

local function formatting()

  local system_config = vim.fn.stdpath "config" .. "buf.yaml"
  local project_config = vim.fn.getcwd() .. "buf.yaml"

  local format_args = { "--config" }

  if vim.fn.filereadable(project_config) == 1 then
    table.insert(format_args, project_config)
  else
    table.insert(format_args, system_config)
  end
  return format_args
end

local function diagnostic()
  local system_config = vim.fn.stdpath("config") .. "buf.yaml"
  local project_config = vim.fn.getcwd() .. "buf.yaml"

  local buf_lint = require("lint").linters.buf_lint
  if not utils.contains_arg(buf_lint.args, "--config") then
    table.insert(buf_lint.args, "--config")
  end
  if vim.fn.filereadable(project_config) == 1 then
    table.insert(buf_lint.args, project_config)
  else
    table.insert(buf_lint.args, system_config)
  end
  return buf_lint.args
end

---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      ---@diagnostic disable: missing-fields
      config = {
        bufls = {
          filetypes = { "proto" },
          single_file_support = true,
          on_attach = function()
            astrocore.set_mappings({
              n = {
                ["<Leader>lc"] = {
                  function()
                    local buf_path = vim.fn.getcwd() .. "buf.yaml"
                    local buf_gen_path = vim.fn.getcwd() .. "buf.gen.yaml"
                    if not utils.file_exists(buf_path) then
                      local confirm = vim.fn.confirm(
                        "File `buf.yaml` Not Exist, Create it ?",
                        "&Yes\n&No",
                        1,
                        "Question"
                      )
                      if confirm == 1 then create_buf_config_file() end
                    end
                    if not utils.file_exists(buf_gen_path) then
                      local confirm = vim.fn.confirm(
                        "File `buf.gen.yaml` Not Exist, Create it ?",
                        "&Yes\n&No",
                        1,
                        "Question"
                      )
                      if confirm  == 1 then create_buf_gen_config_file() end
                    end
                  end,
                  desc = "Create Buf Config File",
                },
              },
            }, { buffer = true })
          end,
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      -- Ensure that opts.ensure_installed exists and is a table or string "all".
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "proto" })
      end
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(
        opts.ensure_installed,
        { "buf" }
      )
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        buf = {
          prepend_args = formatting()
        }
      },
      formatters_by_ft = {
        proto = { "buf" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        buf_lint = {
          args = diagnostic()
        }
      },
      linters_by_ft = {
        proto = { "buf_lint" },
      },
    },
  },
}
