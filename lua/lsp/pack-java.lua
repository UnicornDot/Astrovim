local astrocore = require("astrocore")

return {
  {
    "nvim-java/nvim-java",
    lazy = true,
    opts = {},
    specs = {
      { "mfussenegger/nvim-jdtls", optional = true, enabled = false },
      {
        "AstroNvim/astrolsp",
        optional = true,
        ---@type AstroLSPOpts
        opts = {
          servers = { "jdtls" },
          handlers = {
            jdtls = function(server, opts)
              require("lazy").load { plugins = { "nvim-java" } }
              require("lspconfig")[server].setup(opts)
            end,
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
        opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "java" })
      end
    end
  }
}
