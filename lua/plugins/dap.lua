local utils = require "astrocore"
local prefix_dap = "<Leader>fd"
local prefix_debug = "<Leader>d"
---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          [prefix_dap] = {
            desc = "Find dap",
          },
          [prefix_dap .. "c"] = {
            function() require("telescope").extensions.dap.commands() end,
            desc = "Telescope DAP commands",
          },
          [prefix_dap .. "f"] = {
            function() require("telescope").extensions.dap.frames() end,
            desc = "Telescope DAP frames",
          },
          [prefix_dap .. "g"] = {
            function() require("telescope").extensions.dap.configurations() end,
            desc = "Telescope DAP configurations",
          },
          [prefix_dap .. "l"] = {
            function() require("telescope").extensions.dap.list_breakpoints() end,
            desc = "Telescope DAP list breakpoints",
          },
          [prefix_dap .. "v"] = {
            function() require("telescope").extensions.dap.variables() end,
            desc = "Telescope DAP variables",
          },
          [prefix_debug .. "q"] = {
            function() require("dap").terminate() end,
            desc = "Terminal Session(S-F5)",
          },
          [prefix_debug .. "Q"] = {
            function() require("dap").close() end,
            desc = "Close Session",
          },
          [prefix_debug .. "j"] = {
            function() require("dap").down() end,
            desc = "Down Strace",
          },
          [prefix_debug .. "k"] = {
            function() require("dap").up() end,
            desc = "Up Strace",
          },
          [prefix_debug .. "p"] = {
            function() require("dap.ui.widgets").preview() end,
            desc = "Debugger Preview",
          },
          [prefix_debug .. "P"] = { function() require("dap").pause() end, desc = "Pause (F6)" },
          [prefix_debug .. "u"] = {
            function() require("dapui").toggle { layout = 2, reset = true } end,
            desc = "Toggle Tray Debugger UI and reset layout",
          },
          [prefix_debug .. "U"] = {
            function() require("dapui").toggle { reset = true } end,
            desc = "Toggle All Debugger UI and reset layout",
          },
          [prefix_debug .. "r"] = {
            function() require("dap").run_last() end,
            desc = "Run Last",
          },
          [prefix_debug .. "R"] = {
            function() require("dap").restart_frame() end,
            desc = "Restart (C-F5)",
          },
          [prefix_debug .. "d"] = {
            ---@diagnostic disable-next-line: missing-parameter
            function() require("dapui").float_element() end,
            desc = "Open Dap UI Float Element",
          },
          ["<F9>"] = {
            function() require("persistent-breakpoints.api").toggle_breakpoint() end,
            desc = "Debugger: Toggle Breakpoint",
          },
          [prefix_debug .. "b"] = {
            function() require("persistent-breakpoints.api").toggle_breakpoint() end,
            desc = "Toggle Breakpoint (F9)",
          },
          [prefix_debug .. "B"] = {
            function() require("persistent-breakpoints.api").clear_all_breakpoints() end,
            desc = "Clear All Breakpoints",
          },
          [prefix_debug .. "C"] = {
            function() require("persistent-breakpoints.api").set_conditional_breakpoint() end,
            desc = "Conditional Breakpoint (S-F9)",
          },
          ["<F21>"] = {
            function() require("persistent-breakpoints.api").set_conditional_breakpoint() end,
            desc = "Conditional Breakpoint (S-F9)",
          },
          [prefix_debug .. "S"] = {
            function() require("dap").run_to_cursor() end,
            desc = "Run To Cursor",
          },
          [prefix_debug .. "s"] = {
            function()
              local w = require "dap.ui.widgets"
              w.centered_float(w.sessions, {})
            end,
            desc = "Switch Debug Session",
          },
          [prefix_debug .. "G"] = {
            require("utils").create_launch_json,
            desc = "Create Dap Launch Json"
          },
          [prefix_debug .. "g"] = {
            function() vim.cmd [[DapShowLog]] end,
            desc = "Show Dap Log",
          },
          [prefix_debug .. "h"] = {
            function() require("dap.ui.widgets").hover()end,
            desc = "Debugger Hover",
          }
        },
      },
    },
  },
  {
    "Weissle/persistent-breakpoints.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      return require("astrocore").extend_tbl(opts, {
        load_breakpoints_event = { "BufReadPost" },
      })
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    event = "VeryLazy",
    opts = {
      commented = true,
      enabled = true,
      enabled_commands = true,
      only_first_definition = true,
      clear_on_continue = false,
      -- virt_text_pos = "eol",
      highlight_changed_variables = true,
      all_frames = false,
      virt_lines = true,
      show_stop_reason = true,
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    commit = "317963ac9db86ebb9f2c4010d0d978fc06d493aa",
    config = function(_, opts)
      local dap, dapui = require "dap", require "dapui"
      dap.listeners.after.event_initialized["dapui_config"] = function()
        require("dapui").open { layout = 2, reset = true }
      end
      dapui.setup(opts)
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-dap.nvim",
    },
    opts = function() require("telescope").load_extension "dap" end,
  },
}
