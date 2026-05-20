return {
  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    specs = {
      {
        "saghen/blink.cmp",
        lazy = true,
        opts = function(_, opts)
          opts.snippets = vim.tbl_deep_extend("keep", opts.snippets, {
            preset = "luasnip"
          })
        end
      }
    },
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- load snippets paths
      require("luasnip.loaders.from_vscode").lazy_load {
        paths = { vim.fn.stdpath "config" .. "/snippets" },
      }
    end,
  },
  {
    "rafamadriz/friendly-snippets",
    lazy = true
  },

}
