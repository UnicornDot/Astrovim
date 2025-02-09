return {
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    specs = {
      { "stevearc/aerial.nvim", optional = true, enabled = false },
      { "AstroNvim/astroui", opts = { icons = { Trouble = "󱍼" } } },
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings or {}
          local prefix = "<Leader>x"
          maps.n[prefix] = { desc = require("astroui").get_icon("Trouble", 1, true) .. "Trouble" }
          maps.n[prefix .. "X"] = { "<Cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" }
          maps.n[prefix .. "x"] = { "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer Diagnostics (Trouble)" }
          maps.n[prefix .. "l"] = { "<Cmd>Trouble loclist toggle<CR>", desc = "Location List (Trouble)" }
          maps.n[prefix .. "q"] = { "<Cmd>Trouble quickfix toggle<CR>", desc = "Quickfix List (Trouble)" }
          maps.n["[q"] = {
            function()
              if require("trouble").is_open() then
                require("trouble").prev { skip_group = true, jump = true }
              else
                local ok, err  = pcall(vim.cmd.cprev)
                if not ok then
                  vim.notify(err, vim.log.levels.ERROR)
                end
              end
            end,
            desc = "Previous Trouble/Quickfix Item"
          }
          maps.n["]q"] = {
            function()
              if require("trouble").is_open() then
                require("trouble").next { skip_groups = true, jump = true }
              else
                local ok, err = pcall(vim.cmd.cnext)
                if not ok then
                  vim.notify(err, vim.log.levels.ERROR)
                end
              end
            end,
            desc = "Next Trouble/QuickFix Item"
          }
        end,
      },
    },
    opts = function(_, opts)
      if not opts.icons then opts.icons = {} end
      if not opts.icons.kinds then
        opts.icons.kinds = {
          Array = " ",
          Boolean = "󰨙 ",
          Class = " ",
          Constant = "󰏿 ",
          Constructor = " ",
          Enum = " ",
          EnumMember = " ",
          Event = " ",
          Field = " ",
          File = " ",
          Function = "󰊕 ",
          Interface = " ",
          Key = " ",
          Method = "󰊕 ",
          Module = " ",
          Namespace = "󰦮 ",
          Null = " ",
          Number = "󰎠 ",
          Object = " ",
          Operator = " ",
          Package = " ",
          Property = " ",
          String = " ",
          Struct = "󰆼 ",
          TypeParameter = " ",
          Variable = "󰀫 ",
        }
      end
      for kind, _ in pairs(opts.icons.kinds) do
        local icon, _, _ = require("mini.icons").get("lsp", kind)
        opts.icons.kinds[kind] = icon .. " "
      end
      return vim.tbl_deep_extend("force", opts, {
        modes = {
          lsp = {
            win = { position = "right" },
          }
        },
        keys = {
          ["<ESC>"] = "close",
          ["q"] = "close",
          ["<C-E>"] = "close",
        },
        auto_preview = true, -- automatically open preview when on an item
        auto_refresh = true, -- auto refresh when open
      })
    end,
  },
  { "lewis6991/gitsigns.nvim", opts = { trouble = true } },
}
