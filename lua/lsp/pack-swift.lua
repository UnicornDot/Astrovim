return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "codelldb" })
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "codelldb" })
    end,
  },
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@type function
    opts = function(_, opts)
      require("astrocore").extend_tbl(opts, {
        servers = { "sourcekit" },
        config = {
          sourcekit= {
            capabilities = {
              workspace = {
                didChangeWatchedFiles = {
                  dynamicRegistration = true,
                }
              }
            }
          }
        }
      })
      vim.lsp.enable("sourcekit")
      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP Actions',
        callback = function()
            vim.keymap.set('n', 'M', vim.lsp.buf.hover, {noremap = true, silent = true})
            vim.keymap.set('n', 'gra', vim.lsp.buf.code_action, {noremap = true, silent = true})
            vim.keymap.set('n', 'grd', vim.lsp.buf.definition, {noremap = true, silent = true})
            vim.keymap.set('n', 'grt', vim.lsp.buf.type_definition, {noremap = true, silent = true})
            vim.keymap.set('n', 'gri', vim.lsp.buf.implementation, {noremap = true, silent = true})
            vim.keymap.set('n', 'grn', vim.lsp.buf.rename, {noremap = true, silent = true})
            vim.keymap.set('n', 'grr', vim.lsp.buf.references, {noremap = true, silent = true})
            vim.keymap.set('n', "grx", vim.lsp.codelens.run, { noremap = true, silent = true})
        end,
      })
    end,
  },
}
