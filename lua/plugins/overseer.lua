local astrocore = require("astrocore")
return {
  {
    "stevearc/overseer.nvim",
    ---@param opts overseer.Config
    event = "User AstroFile",
    opts = function(_, opts)
      local window_scaling_factor = 0.3
      local height = require("utils").size(vim.o.lines, window_scaling_factor)
      local width = require("utils").size(vim.o.columns, window_scaling_factor)
      return vim.tbl_deep_extend('force', opts,  {
        dap = false,
        templates = { "make", "cargo", "shell", "run_script", "npm", "run_web", "run_python" },
        task_list = {
          width = width,
          height = height,
          default_detail = 1,
          direction = "bottom",
          bindings = {
            ["<C-h>"] = false,
            ["<C-j>"] = false,
            ["<C-k>"] = false,
            ["<C-l>"] = false,
            q = "<Cmd>close<CR>"
          },
          -- Aliases for bundles of components. Redefine the builtins, or create your own.
          component_aliases = {
            -- Most tasks are initialized with the default components
            default = {
              { "display_duration", detail_level = 2 },
              "on_output_summarize",
              "on_exit_set_status",
              { "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
            },
            -- Tasks from tasks.json use these components
            default_vscode = {
              "default",
              "on_result_diagnostics",
            },
          },
          bundles = {
            -- When saving a bundle with OverseerSaveBundle or save_task_bundle(), filter the tasks with
            -- these options (passed to list_tasks())
            save_task_opts = {
              bundleable = true,
            },
            -- Autostart tasks when they are loaded from a bundle
            autostart_on_load = false,
          },
        }
      })
    end,
    specs = {
      {
        "mfussenegger/nvim-dap",
        optional = true,
        opts = function() require("overseer").enable_dap() end,
      },
      {
        "nvim-neotest/neotest",
        optional = true,
        opts = function(_, opts)
          opts = opts or {}
          opts.consumers = opts.consumers or {}
          opts.consumers.overseer = require("neotest.consumers.overseer")
        end
      },
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          local maps = opts.mappings or {}
          if maps then
            maps.n['<Leader>rt'] = { "<cmd>OverseerToggle<cr>", desc = "Toggle overseer task list" }
            maps.n['<Leader>rr'] = { "<cmd>OverseerRun<cr>", desc = "List overseer run templates" }
            maps.n['<Leader>rc'] = { "<Cmd>OverseerRunCmd<CR>", desc = "Run Command" }
            maps.n['<Leader>rq'] = { "<Cmd>OverseerQuickAction<CR>", desc = "Quick Action" }
            maps.n['<Leader>ra'] = { "<Cmd>OverseerTaskAction<CR>", desc = "Task Action" }
            maps.n['<Leader>ri'] = { "<Cmd>OverseerInfo<CR>", desc = "Overseer Info" }
          end
          opts.mappings = maps
        end
      },
    },
    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)
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
    -- custom behavior of make templates
  }
}

