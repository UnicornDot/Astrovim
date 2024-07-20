return {
  {

    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
      local maps = opts.mappings
      if maps then
        maps.n['<leader>rt'] = { "<cmd>OverseerToggle<cr>", desc = "Toggle overseer task list" }
        maps.n['<leader>rr'] = { "<cmd>OverseerRun<cr>", desc = "List overseer run templates" }
      end
      opts.mappings = maps
    end
  },
  {
    "stevearc/overseer.nvim",
    config = function()
      local overseer = require("overseer")
      overseer.setup({
        dap = false,
        templates = { "make", "cargo", "shell", "run_script", "npm", "run_web" },
        task_list = {
          direction = "left",
          bindings = {
            ["<C-u>"] = false,
            ["<C-d>"] = false,
            ["<C-h>"] = false,
            ["<C-j>"] = false,
            ["<C-k>"] = false,
            ["<C-l>"] = false,
          },
        }
      })
      -- custom behavior of make templates
      overseer.add_template_hook(
        {
          module = "^make$",
        },
        function(task_defn, util)
          util.add_component(task_defn, { "on_output_quickfix", open_on_exit = "failure"})
          util.add_component(task_defn, "on_complete_notify")
          util.add_component(task_defn, { "display_duration", detail_level = 1 })
        end
      )
    end
  }
}

