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
              event = "User",
              desc = "forwards opencode's SSE as an OpencodeEvent",
              pattern = "OpencodeEvent:*",
              callback = function(args)
                ---@type opencode.server.Event
                local event = args.data.event
                ---@type number
                local port = args.data.port
                vim.notify(vim.inspect(event))
                if event.type == "session.idle" then
                  vim.notify("`opencode` finished responding")
                end
              end,
            },
          },
        },
      })
    end,
  },
}
