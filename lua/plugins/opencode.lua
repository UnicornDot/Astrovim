local astrocore = require("astrocore")

local prefix = "<Leader>a"

---@type LazySpec
return {
  "nickjvandyke/opencode.nvim",
  lazy = true,
  version = "*", -- Latest stable release
  specs = {
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
    {
      "AstroNvim/astrocore",
      optional = true,
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n[prefix] = { desc = " Agent Mode" }
        maps.n[prefix .. "a"] = { function() require("opencode").ask("@this: ", { submit = true }) end, desc = "Ask opencode…" }
        maps.n[prefix .. "x"] = { function() require("opencode").select() end, desc = "Execute opencode action…" }
        maps.n[prefix .. "h"] = { function() require("opencode").toggle() end, desc = "Toggle opencode" }
        maps.n[prefix .. "o"] = { function() return require("opencode").operator("@this ") end, desc = "Add range to opencode", expr = true }
        maps.n[prefix .. "p"] = { function() return require("opencode").operator("@this ") .. "_" end, desc = "Add line to opencode", expr = true }
        maps.n[prefix .. "d"] = { function() require("opencode").command("session.half.page.down") end,  desc = "Scroll opencode down" }
        maps.n[prefix .. "u"] = { function() require("opencode").command("session.half.page.up") end,  desc = "Scroll opencode up" }

        maps.x[prefix .. "a"] = { function() require("opencode").ask("@this: ", { submit = true }) end, desc = "Ask opencode…" }
        maps.x[prefix .. "x"] = { function() require("opencode").select() end, desc = "Execute opencode action…" }
        maps.x[prefix .. "o"] = { function() return require("opencode").operator("@this ") end, desc = "Add range to opencode", expr = true }

        maps.t[prefix .. "."] = { function() require("opencode").toggle() end, desc = "Toggle opencode" }

      end,
    },
  },
  config = function()
    local opencode_cmd = 'opencode --port'
    ---@type snacks.terminal.Opts
    local snacks_terminal_opts = {
      win = {
        position = 'right',
        style = "default",
        enter = true,
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
