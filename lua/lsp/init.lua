local methods = vim.lsp.protocol.Methods

local rename_handler = vim.lsp.handlers[methods.textDocument_rename]
local auto_save_after_rename_handler = function(err, result, ctx, config)
  rename_handler(err, result, ctx, config)
  if not result or not result.documentChanges then return end
  for _, documentChange in pairs(result.documentChanges) do
    local textDocument = documentChange.textDocument
    if textDocument and textDocument.uri then
      local bufnr = vim.uri_to_bufnr(textDocument.uri)
      if vim.fn.bufload(bufnr) == 1 then
        vim.schedule(function()
          vim.api.nvim_buf_call(bufnr, function() vim.cmd "write" end)
        end)
      end
    end
  end
end

-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: we highly recommend setting up the lua Language Server(`:LspInstall lua_ls`)

return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  ---@diagnostic disable-next-line: assign-type-mismatch
  opts = function(_, opts)
    local mappings = require("keymapping").lsp_mappings(opts.mappings)
    return require("astrocore").extend_tbl(opts, {
      features = {
        -- Configuration table of features provided by AstroLSP
        autoformat = false, -- enable or disable auto formatting on start
        codelens = true, -- enable/disable codelens refresh on start
        lsp_handlers = true, -- enable/disable setting of lsp_handlers
        semantic_tokens = true, -- enable/disable semantic token highlighting
        inlay_hints = true,
        signature_help = false,
      },
      -- Configuration options for controlling formatting with language servers
      formatting = {
        -- control auto formatting on save
        format_on_save = false,
        -- disable formatting capabilities for specific language servers
        disabled = {},
        -- default format timeout
        timeout_ms = 20000,
      },
      -- mappings to be set up on attaching of a language server
      mappings = mappings,
      on_attach = function()
        require("lspconfig.ui.windows").default_options.border = "rounded"
      end,
      lsp_handlers = {
        [methods.textDocument_rename] = auto_save_after_rename_handler,
      },
    })
  end,
}
