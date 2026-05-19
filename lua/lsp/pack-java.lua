return {
  "nvim-java/nvim-java",
  lazy = true,
  opts = {},
  specs = {
    { "mfussenegger/nvim-jdtls", optional = true, enabled = false },
    {
      "AstroNvim/astrolsp",
      optional = true,
      ---@type function
      opts = function(_, opts)
        local astrocore  = require("astrocore")
        opts.servers = astrocore.list_insert_unique(opts.servers or {}, { "jdtls" })
        opts.handlers = astrocore.extend_tbl(opts.handlers or {}, {
          jdtls = function(server)
            require("lazy").load { plugins = { "nvim-java" } }
            vim.lsp.enable(server)
          end,
        })
      end,
    },
  },
}
