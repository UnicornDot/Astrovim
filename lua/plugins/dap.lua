local astrocore = require "astrocore"
local utils = require "utils"

local dap_win_open = function()
  local windows = require "dapui.windows"
  local is_window_open = false
  for i = 1, #windows.layouts, 1 do
    if windows.layouts[i]:is_open() then is_window_open = true end
  end
  return is_window_open
end

local close_all_win = function()
  local windows = require "dapui.windows"
  for i = 1, #windows.layouts, 1 do
    windows.layouts[i]:close()
  end
end

local choose_layout = function(callback)
  local elements = {
      "repl&console",
      "console&scopes",
      "console",
      "repl",
      "stacks",
      "breakpoints",
      "watches",
      "scopes",
      "all elements"
  }
  Snacks.picker.select(
    elements,
    { prompt = "Select  Dap Layout: " },
    function(select, _)
      if not select then return end
      if dap_win_open() then close_all_win() end
      local dapui = require("dapui")

      if select == "console&scopes" then dapui.open { layout = 1, reset = true }
      elseif select == "console" then dapui.open { layout = 2, reset = true }
      elseif select == "repl" then dapui.open { layout = 3, reset = true }
      elseif select == "stacks" then dapui.open { layout = 4, reset = true }
      elseif select == "breakpoints" then dapui.open { layout = 5, reset = true }
      elseif select == "watches" then dapui.open { layout = 6, reset = true }
      elseif select == "scopes" then dapui.open { layout = 7, reset = true }
      elseif select == "repl&console" then dapui.open { layout = 9, reset = true }
      else
        dapui.open { layout = 8, reset = true }
        dapui.open { layout = 9, reset = true }
      end
      if callback then callback() end
    end
  )
end

local pick_element = function()
  local dapui = require("dapui")
  local window = {
    width = utils.size(vim.o.columns, 0.8),
    height = utils.size(vim.o.lines, 0.8),
    position = "center",
    enter = true,
  }
  Snacks.picker.select(
    { "console", "repl", "stacks", "breakpoints", "watches", "scopes" },
    { prompt = "Pick Dap Element: " },
    function(select, _)
      if not select then return end
      dapui.float_element(select, window)
    end
  )
end

local prefix_debug = "<Leader>d"
---@type LazySpec
return {
  {
    "Weissle/persistent-breakpoints.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      return astrocore.extend_tbl(opts, {
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
      clear_on_continue = true,
      -- virt_text_pos = "eol",
      highlight_changed_variables = true,
      all_frames = false,
      virt_lines = true,
      show_stop_reason = true,
    },
  },
  {
    "bramdelta/blink-dap",
    specs = {
      {
        "saghen/blink.cmp",
        optional = true,
        opts = function(_, opts)
          return astrocore.extend_tbl(opts, {
            sources = {
              default = astrocore.list_insert_unique(opts.sources.default or {}, { "dap" }),
              providers = {
                dap = {
                  name = "dap", -- This should match the source specified above
                  module = "blink-dap",
                  opts = {
                    -- If you want to include DAP commands like `.scopes` as well
                    include_repl = true,
                    filetypes = {
                      -- The name of the adapter `type` in your debugger configuration file
                      python = {
                        -- What trigger characters to use for additional completions, i.e.
                        -- foo.bar would mean to use . to prompt for available properties of foo
                        trigger_characters = { "." },
                      },
                    },
                    -- Which filetypes to enable completion for.
                    -- Use `:echo &filetype` to find this per buffer
                    dap_filetypes = { "dap-repl" },
                  },
                },
              },
            },
          })
        end,
      },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    specs = {
      {
        "AstroNvim/astrocore",
        ---@type function
        opts = function(_, opts)
          local maps = opts.mappings or {}
          local dap = require("dap")
          local dapui = require("dapui")
          local widget = require("dap.ui.widgets")
          local bpapi = require("persistent-breakpoints.api")
          local dap_start = function()
            if not dap_win_open() then
              choose_layout(function() dap.continue() end)
            else
              dap.continue()
            end
          end
          local toggle_ui = function()
            if dap_win_open() then close_all_win() else choose_layout() end
          end

          maps.n[prefix_debug .. "q"] = { function() dap.terminate() end, desc = "Terminal Session(S-F5)" }
          maps.n[prefix_debug .. "Q"] = { function() dap.close() end, desc = "Close Session" }
          maps.n[prefix_debug .. "j"] = { function() dap.down() end, desc = "Down Strace" }
          maps.n[prefix_debug .. "k"] = { function() dap.up() end, desc = "Up Strace" }
          maps.n[prefix_debug .. "r"] = { function() dap.run_last() end, desc = "Run Last" }
          maps.n[prefix_debug .. "s"] = { function() dap.run_to_cursor() end, desc = "Run To Cursor" }
          maps.n[prefix_debug .. "R"] = { function() dap.restart_frame() end, desc = "Restart (C-F5)" }
          maps.n[prefix_debug .. "p"] = { function() dap.pause() end, desc = "Pause (F6)" }
          maps.n[prefix_debug .. "l"] = { function() vim.cmd [[DapShowLog]] end, desc = "Show Dap Log" }
          maps.n[prefix_debug .. "c"] = { function() dap_start() end, desc = "Start Debug" }
          maps.n[prefix_debug .. "u"] = { function() toggle_ui() end, desc = "Toggle Debugger UI and reset layout" }
          maps.n[prefix_debug .. "U"] = { function() dapui.toggle() end, desc = "Reset All Layout" }
          maps.n[prefix_debug .. "f"] = { function() pick_element() end, desc = "Pick Float Dap Element" }
          maps.n[prefix_debug .. "d"] = { function() choose_layout() end, desc = "Switch dap ui element" }
          maps.n["<F9>"]  = { function() bpapi.toggle_breakpoint() end, desc = "Debugger: Toggle Breakpoint" }
          maps.n["<F21>"] = { function() bpapi.set_conditional_breakpoint() end, desc = "Conditional Breakpoint (S-F9)" }
          maps.n[prefix_debug .. "b"] = { function() bpapi.toggle_breakpoint() end, desc = "Toggle Breakpoint (F9)" }
          maps.n[prefix_debug .. "B"] = { function() bpapi.clear_all_breakpoints() end, desc = "Clear All Breakpoints" }
          maps.n[prefix_debug .. "C"] = { function() bpapi.set_conditional_breakpoint() end, desc = "Conditional Breakpoint (S-F9)" }
          maps.n[prefix_debug .. "h"] = { function() widget.hover() end, desc = "Debugger Hover" }
          maps.n[prefix_debug .. "P"] = { function() widget.preview() end, desc = "Debugger Preview" }
          maps.n[prefix_debug .. "S"] = { function() widget.centered_float(w.sessions, {}) end, desc = "Switch Debug Session" }
          maps.n[prefix_debug .. "G"] = { utils.create_launch_json, desc = "Create Dap Launch Json" }
        end
      },
    },
    opts = {
      layouts = {
        {
          elements = {
            { id = "console", size = 0.4 },
            { id = "scopes", size = 0.6 },
          },
          size = utils.size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "top" or "bottom"
        },
        {
          elements = {
            { id = "console", size = 1 },
          },
          size = utils.size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          elements = {
            { id = "repl", size = 1 },
          },
          size = utils.size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          elements = {
            { id = "stacks", size = 1 },
          },
          size = utils.size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          elements = {
            { id = "breakpoints", size = 1 },
          },
          size = utils.size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          elements = {
            { id = "watches", size = 1 },
          },
          size = utils.size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          elements = {
            { id = "scopes", size = 1 },
          },
          size = utils.size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          -- You can change the order of elements in the sidebar
          elements = {
            {
              id = "scopes",
              size = 0.25, -- can be float or integer
            },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = utils.size(vim.o.columns, 0.2),
          position = "right", -- can be "left" or right
        },
        {
          elements = {
            { id = "repl", size = 0.4 },
            { id = "console", size = 0.6 },
          },
          size = utils.size(vim.o.lines, 0.25),
          position = "bottom", --- can be "bottom" or "top"
        },
      },
      render = {
        max_type_length = 100, -- can be integer or nil
        max_value_lines = 100, -- can be integer or nil
        indent = 1,
      },
    },
    config = function(_, opts)
      local dapui = require "dapui"
      local events = {
        "event_continued",
        "event_exited",
        "event_initialized",
        "event_invalidated",
        "event_stopped",
        "event_terminated",
        "event_thread",
        "attach",
        "continue",
        "disconnect",
        "initialize",
        "launch",
        "next",
        "pause",
        "restart",
        "restartFrame",
        "stepBack",
        "stepIn",
        "stepInTargets",
        "stepOut",
        "terminate",
        "terminateThreads",
      }
      for _, event in ipairs(events) do
        local dap = require "dap"
        local controls = require("dapui.controls")
        dap.listeners.after[event].dapui_config = function() controls.refresh_control_panel() end
        dap.listeners.before[event].dapui_config = function() controls.refresh_control_panel() end
      end

      dapui.setup(opts)
    end,
  },
}
