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
        autoformat = false, -- enable or disable auto formatting on start
        codelens = true, -- enable/disable codelens refresh on start
        lsp_handlers = true, -- enable/disable setting of lsp_handlers
        semantic_tokens = true, -- enable/disable semantic token highlighting
        inlay_hints = true,
        signature_help = true,
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
      -- mappings to be set up on attaching of a language server
      mappings = mappings,
      on_attach = function()
        require("lspconfig.ui.windows").default_options.border = "rounded"
      end,
    })
  end,
}
