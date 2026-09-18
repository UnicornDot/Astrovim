local astrocore = require "astrocore"

return {
  {
    "moonbit-community/moonbit.nvim",
    lazy = true,
    ft = { "moonbit" },
    opts = {
      mooncakes = {
        virtual_text = true, -- virtual text showing suggestions
        use_local = true, -- recommended, use index under ~/.moon
      },
      -- optionally disable the treesitter integration
      treesitter = {
        enabled = true,
        -- Set false to disable automatic installation and updating of parsers.
        auto_install = false,
      },
      -- configure the language server integration
      -- set `lsp = false` to disable the language server integration
      lsp = {
        -- set to false to use the legacy language server
        native = true,
        -- provide an `on_attach` function to run when the language server starts
        on_attach = function(client, bufnr) end,
        -- provide client capabilities to pass to the language server
        capabilities = vim.lsp.protocol.make_client_capabilities(),
      },
      -- configure jsonls schema integration (enabled by default)
      -- set `jsonls = false` to disable
      jsonls = {
        -- optional extra jsonls settings to merge
        settings = {},
      },
    },
  },
  {
    "nvim-neotest/neotest",
    lazy = true,
    specs = {
      "moonbit-community/moonbit.nvim",
    },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(opts.adapters, require "neotest-moonbit")
    end,
  },
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      return astrocore.extend_tbl(opts, {
        sources = {
          -- add mooncake to your completion providers
          default = astrocore.list_insert_unique(opts.sources.default or {}, { "mooncake" }),
          providers = {
            mooncake = {
              name   = 'Mooncakes',
              module = 'moonbit.mooncakes.completion.blink',
              opts   = { max_items = 100 },
            },
          },
        },
    })
    end,
  }
}
