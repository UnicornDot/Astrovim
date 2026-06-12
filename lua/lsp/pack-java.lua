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
        opts.config = vim.tbl_deep_extend("keep", opts.config or {}, {
          jdtls = {
            settings = {
              java = {
                configuration = {
                  runtimes = {
                    {
                      name = "JavaSE-11",
                      path = "~/.jdks/corretto-11.0.31",
                    },
                    {
                      name = "JavaSE-17",
                      path = "~/.jdks/corretto-17.0.19",
                      default = true,
                    },
                    {
                      name = "JavaSE-21",
                      path = "~/.jdks/corretto-21.0.10",
                    },
                    {
                      name = "JavaSE-25",
                      path = "~/.jdks/corretto-25.0.1",
                    }
                  }
                }
              }
            }
          }
        })
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
