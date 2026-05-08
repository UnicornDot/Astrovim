local prefix = "<Leader>a"

---@type LazySpec
return {
  "nickjvandyke/opencode.nvim",
  version = "*", -- Latest stable release
  dependencies = {
    {
      -- `snacks.nvim` integration is recommended, but optional
      ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
      "folke/snacks.nvim",
      optional = true,
      opts = {
        input = {}, -- Enhances `ask()`
        picker = { -- Enhances `select()`
          actions = {
            opencode_send = function(...) return require("opencode").snacks_picker_send(...) end,
          },
          win = {
            input = {
              keys = {
                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            [prefix] = { desc = " Agent Mode" },
            [prefix .. "a"] = { function() require("opencode").ask("@this: ", { submit = true }) end, desc = "Ask opencode…" },
            [prefix .. "x"] = { function() require("opencode").select() end, desc = "Execute opencode action…" },
            [prefix .. "."] = { function() require("opencode").toggle() end, desc = "Toggle opencode" },
            [prefix .. "o"] = { function() return require("opencode").operator("@this ") end, desc = "Add range to opencode", expr = true },
            [prefix .. "p"] = { function() return require("opencode").operator("@this ") .. "_" end, desc = "Add line to opencode", expr = true },
            [prefix .. "d"] = { function() require("opencode").command("session.half.page.down") end,  desc = "Scroll opencode down" },
            [prefix .. "u"] = { function() require("opencode").command("session.half.page.up") end,  desc = "Scroll opencode up" }
          },
        x = {
          [prefix .. "a"] = { function() require("opencode").ask("@this: ", { submit = true }) end, desc = "Ask opencode…" },
          [prefix .. "x"] = { function() require("opencode").select() end, desc = "Execute opencode action…" },
          [prefix .. "o"] = { function() return require("opencode").operator("@this ") end, desc = "Add range to opencode", expr = true },
        },
        t = {
          [prefix .. "."] = { function() require("opencode").toggle() end, desc = "Toggle opencode" }},
        }
      },
    },
  },
  config = function()
    local opencode_cmd = 'opencode --port'
    ---@type snacks.terminal.Opts
    local snacks_terminal_opts = {
      win = {
        position = 'float',
        enter = false,
        on_win = function(win)
          require('opencode.terminal').setup(win.win)
        end,
      }
    }
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      server = {
        start = function()
          require('snacks.terminal').open(opencode_cmd, snacks_terminal_opts)
        end,
        stop = function()
          require('snacks.terminal').get(opencode_cmd, snacks_terminal_opts):close()
        end,
        toggle = function()
          require('snacks.terminal').toggle(opencode_cmd, snacks_terminal_opts)
        end,
      },
    }
  end,
}
