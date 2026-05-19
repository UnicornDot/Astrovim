local astrocore = require "astrocore"
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "codelldb" })
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    lazy = true,
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "codelldb" })
    end,
  },
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@type function
    opts = function(_, opts)
      opts.servers = astrocore.list_insert_unique(opts.servers or {}, { "sourcekit" })
      opts.config = vim.tbl_deep_extend("keep", opts.config, {
        sourcekit = {
          root_dir = require("lspconfig.util").root_pattern("Package.swift", "Package.resolved", ".git"),
          filetypes = { "swift" },
          capabilities = {
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = true,
              },
            },
          },
          on_attach = function()
            vim.keymap.set("n", "M", vim.lsp.buf.hover, { noremap = true, silent = true })
            vim.keymap.set("n", "gra", vim.lsp.buf.code_action, { noremap = true, silent = true })
            vim.keymap.set("n", "grd", vim.lsp.buf.definition, { noremap = true, silent = true })
            vim.keymap.set("n", "grt", vim.lsp.buf.type_definition, { noremap = true, silent = true })
            vim.keymap.set("n", "gri", vim.lsp.buf.implementation, { noremap = true, silent = true })
            vim.keymap.set("n", "grn", vim.lsp.buf.rename, { noremap = true, silent = true })
            vim.keymap.set("n", "grr", vim.lsp.buf.references, { noremap = true, silent = true })
            vim.keymap.set("n", "grx", vim.lsp.codelens.run, { noremap = true, silent = true })
          end,
        },
      })
      vim.lsp.enable "sourcekit"
    end,
  },
}
