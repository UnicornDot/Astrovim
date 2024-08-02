local methods = vim.lsp.protocol.Methods
local inlay_hints_handler = vim.lsp.handlers[methods.textDocument_inlayHint]
local simple_inlay_hint_handler = function(err, result, ctx, config)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client then
    if result == nil then return end
    -- @diagnostic disable-next-line: undefined-field
    result = vim.iter(result):map(function(hint)
      local label = hint.label
      if not (label ~= nil and #label < 5) then hint.label = {} end
      return hint
    end)
    inlay_hints_handler(err, result, ctx, config)
  end
end

return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    features = {
      -- Configuration table of features provided by AstroLSP
      autoformat = false, -- enable or disable auto formatting on start
      codelens = true, -- enable/disable codelens refresh on start
      lsp_handlers = true, -- enable/disable setting of lsp_handlers
      semantic_tokens = true, -- enable/disable semantic token highlighting
      inlay_hints = true,
      diagnostics_mode = 3,
    },
    -- Configuration options for controlling formatting with language servers
    formatting = {
      -- control auto formatting on save
      format_on_save = false,
      -- disable formatting capabilities for specific language servers
      disabled = {},
      -- default format timeout
      timeout_ms = 600000,
    },
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        gl = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" },
        ["M"] = { function() vim.lsp.buf.hover() end, desc = "Hover symbol details", cond = "textDocument/hover" },
        ["K"] = { "5k", desc = "fast move", silent = true },
        ["<Leader>lA"] = {
          function() vim.lsp.buf.code_action { content = { only = { "source", "refactor", "quickfix" } } } end,
        },
        ['gK'] = false,
      },
      i = {
        ["<C-h>"] = {
          function() vim.lsp.buf.signature_help() end,
          desc = "Signature help",
          cond = "textDocument/signatureHelp",
        },
      },
    },
    lsp_handlers = {
      [methods.textDocument_inlayHint] = simple_inlay_hint_handler,
    },
    autocmds = {
      auto_add_lsp_mapping = {
        {
          event = "BufEnter",
          desc = "auto add lsp mapping",
          callback = function()
            -- get current buffer file type
            local ft = vim.bo.filetype
            if ft == "go" then
              require("utils").set_telescope_lsp_mapping()
            elseif ft == "lua" then
              require("utils").set_telescope_lsp_mapping()
            elseif
              require("utils").is_in_list(ft, {
                "javascript",
                "javascriptreact",
                "javascript.jsx",
                "typescript",
                "typescriptreact",
                "typescript.tsx",
                "vue",
              })
            then
              require("utils").set_telescope_lsp_mapping()
            elseif ft == "rust" then
              require("utils").set_telescope_lsp_mapping()
            else
              require("utils").set_native_lsp_mapping()
            end
          end,
        },
      },
    },
  },
}
