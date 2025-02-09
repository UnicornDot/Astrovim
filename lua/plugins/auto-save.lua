return {
  "chaozwn/auto-save.nvim",
  event = { "User AstroFile", "InsertEnter" },
  opts = {
    debounce_delay = 3000,
    print_enabled = false,
    trigger_events = { "TextChanged", "InsertLeave"},
    condition = function(buf)
      local fn = vim.fn
      local utils = require("auto-save.utils.data")
      if fn.getbufvar(buf, "&modifiable") == 1 and utils.not_in(fn.getbufvar(buf, "&filetype"), {}) then
        return fn.mode() == "n"
      end
      return false
    end,
    config = function(_, opts)
      local autoformat_group = vim.api.nvim_create_augroup("AutoformatToggle", { clear = true })

      -- Disable autoforamt before saving
      vim.api.nvim_create_autocmd("User", {
        pattern = "AutoSaveWritePre",
        group = autoformat_group,
        desc = "Disable autoformat before saving",
        callback = function()
          -- Save global autoformat status
          vim.g.OLD_AUTOFORMAT = vim.g.autoformat
          vim.g.autoformat = false

          local old_autoformat_buffers = {}
          --Disable all menually enabled buffers
          for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.b[bufnr].autoformat then
              table.insert(old_autoformat_buffers, bufnr)
              vim.b[bufnr].autoformat = false
            end
          end

          vim.g.OLD_AUTOFORMAT_BUFFERS = old_autoformat_buffers
        end
      })

      -- Re-enable autoformat after saving
      vim.api.nvim_create_autocmd("User", {
        group = autoformat_group,
        pattern = "AutoSaveWritePost",
        desc = "Re-enable autoformat after saving",
        callback = function()
          -- Restore global autoformat status
          vim.g.autoformat = vim.g.OLD_AUTOFORMAT
          -- Re-enable all manually enabled buffers
          for _, bufnr in ipairs(vim.g.OLD_AUTOFORMAT_BUFFERS or {}) do
            vim.b[bufnr].autoformat = true
          end
        end,
      })
      require("auto-save").setup(opts)
    end,
  },
}
