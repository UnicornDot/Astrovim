---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  ---@diagnostic disable-next-line: assign-type-mismatch
  opts = function(_, opts)
    local mappings = require("keymapping").lsp_mappings(opts.mappings)
    return vim.tbl_deep_extend("force", opts, {
      features = {
        -- Configuration table of features provided by AstroLSP
        -- autoformat = false, -- enable or disable auto formatting on start
        codelens = false, -- enable/disable codelens refresh on start
        -- lsp_handlers = true, -- enable/disable setting of lsp_handlers
        semantic_tokens = true, -- enable/disable semantic token highlighting
        inlay_hints = true,
        -- signature_help = true,
      },
      -- Configuration options for controlling formatting with language servers
      formatting = {
        -- control auto formatting on save
        format_on_save = {
          enabled = false,
        },
        -- disable formatting capabilities for specific language servers
        disabled = {},
        -- default format timeout
        timeout_ms = 2000,
      },
      autocmds = {},

      -- mappings to be set up on attaching of a language server
      mappings = mappings,

      -- A custom `on_attach` function to be run after the default `on_attach` function
      -- takes two parameters `client` and `bufnr`  (`:h lsp-attach`)
      on_attach = function()
        -- this would disable semanticTokensProvider for all clients
        -- client.server_capabilities.semanticTokensProvider = nil
      end,
    })
  end,
}
