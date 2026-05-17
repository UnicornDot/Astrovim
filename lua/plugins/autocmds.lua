return {
  {
    "AstroNvim/astrocore",
    ---@type function
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        autocmds = {
          auto_spell = {
            {
              event = "FileType",
              desc = "Enable wrap and spell for text like documents",
              pattern = { "gitcommit", "markdown", "text", "plaintex" },
              callback = function()
                vim.opt_local.wrap = true
                vim.opt_local.spell = true
              end,
            },
          },
          auto_close_dadbod_output = {
            {
              event = "FileType",
              pattern = { "dbout" },
              callback = function(event)
                vim.bo[event.buf].buflisted = false
                vim.schedule(function()
                  vim.keymap.set("n", "q", function() vim.cmd "q!" end, {
                    buffer = event.buf,
                    silent = true,
                    desc = "Quit buffer",
                  })
                end)
              end,
            },
          },
          auto_select_virtualenv = {
            {
              event = "VimEnter",
              desc = "Auto select virtualenv Nvim open",
              pattern = "*",
              callback = function()
                local venv = vim.fn.findfile("pyproject.toml", vim.fn.getcwd() .. ";")
                if venv ~= "" then require("venv-selector").activate_from_path(vim.fn.getcwd()) end
              end,
              once = true,
            },
          },
          auto_opencode_event = {
            {
              event = 'WinEnter',
              desc = "float window transparent bg when unfocus",
              pattern = "*",
              callback = function()
                local zoom_book = require('neo-zoom').zoom_book

                if require('neo-zoom').is_neo_zoom_float()
                then for z, _ in pairs(zoom_book) do vim.wo[z].winbl = 0 end
                else for z, _ in pairs(zoom_book) do vim.wo[z].winbl = 20 end
                end
              end
            }
          },
        },
      })
    end,
  },
}
