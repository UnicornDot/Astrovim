local astrocore = require "astrocore"

local function selene_configured(path)
  return #vim.fs.find("selene.toml", { path = path, upward = true, type = "file" }) > 0
end

---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = function(_, opts)
      vim.tbl_deep_extend("force", opts, {
        ---@diagnostic disable: missing-fields
        config = {
          lua_ls = { settings = { Lua = { hint = { enable = true, arrayIndex = "Disable" } } } },
        },
      })
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "lua", "luap" })
      end
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts) opts.ensure_installed = astrocore.list_insert_unique(
      opts.ensure_installed, 
      { "lua-language-server", "stylua", "selene" }
    ) 
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        lua = { "selene" },
      },
      linters = {
        selene = { condition = function(ctx) return selene_configured(ctx.filenmae) end },
      },
    },
  }
}
