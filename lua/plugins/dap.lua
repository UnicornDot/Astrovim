local utils = require "astrocore"

local is_dap_window_open = function()
  local windows = require("dapui.windows")
  local is_window_open = false
  for i = 1, #windows.layouts, 1 do
    if windows.layouts[i]:is_open() then is_window_open = true end
  end
  return is_window_open
end

local close_all_window = function()
  local windows = require("dapui.windows")
  for i = 1, #windows.layouts, 1 do
    windows.layouts[i]:close()
  end
end

local choose_dap_element = function(callback)
  vim.ui.select({
    "default",
    "console",
    "repl",
    "stacks",
    "breakpoints",
    "watches",
    "scopes",
    "all elements",
  },{prompt = "Select  Dap Layout: ", default = "default"},
    function(select)
      if not select then return end
      if is_dap_window_open() then close_all_window() end
      if select == "default" then
        require("dapui").open { layout = 1, reset = true }
      elseif select == "console" then
        require("dapui").open { layout = 2, reset = true }
      elseif select == "repl" then
        require("dapui").open { layout = 3, reset = true }
      elseif select == "stacks" then
        require("dapui").open { layout = 4, reset = true }
      elseif select == "breakpoints" then
        require("dapui").open { layout = 5, reset = true }
      elseif select == "watches" then
        require("dapui").open { layout = 6, reset = true }
      elseif select == "scopes" then
        require("dapui").open { layout = 7, reset = true }
      else
        require("dapui").open { layout = 8, reset = true }
        require("dapui").open { layout = 9, reset = true }
      end
      if callback then callback() end
  end)
end

local prefix_debug = "<Leader>d"
---@type LazySpec
return {
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
      clear_on_continue = true,
      -- virt_text_pos = "eol",
      highlight_changed_variables = true,
      all_frames = false,
      virt_lines = true,
      show_stop_reason = true,
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    specs = {
      {
        "AstroNvim/astrocore",
        ---@type AstroCoreOpts
        opts = function(_, opts)
          local maps = opts.mappings or {}
          maps.n[prefix_debug .. "q"] = {
            function() require("dap").terminate() end,
            desc = "Terminal Session(S-F5)",
          }
          maps.n[prefix_debug .. "Q"] = {
            function() require("dap").close() end,
            desc = "Close Session",
          }
          maps.n[prefix_debug .. "j"] = {
            function() require("dap").down() end,
            desc = "Down Strace",
          }
          maps.n[prefix_debug .. "k"] = {
            function() require("dap").up() end,
            desc = "Up Strace",
          }
          maps.n[prefix_debug .. "p"] = {
            function() require("dap.ui.widgets").preview() end,
            desc = "Debugger Preview",
          }
          maps.n[prefix_debug .. "P"] = { function() require("dap").pause() end, desc = "Pause (F6)" }
          maps.n[prefix_debug .. "c"] = {
            function()
              local is_window_open = is_dap_window_open()
              if not is_window_open then 
                choose_dap_element(function() require("dap").continue() end)
              else
                require("dap").continue()
              end
            end,
            desc = "Start Debug",
          }
          maps.n[prefix_debug .. "u"] = {
            function()
                local is_window_open = is_dap_window_open()
                if is_window_open then
                  close_all_window()
                else
                  choose_dap_element()
                end
            end,
            desc = "Toggle Tray Debugger UI and reset layout",
          }
          maps.n[prefix_debug .. "U"] = {
            function() require("dapui").toggle { reset = true } end,
            desc = "Toggle All Debugger UI and reset layout",
          }
          maps.n[prefix_debug .. "r"] = {
            function() require("dap").run_last() end,
            desc = "Run Last",
          }
          maps.n[prefix_debug .. "R"] = {
            function() require("dap").restart_frame() end,
            desc = "Restart (C-F5)",
          }
          maps.n[prefix_debug .. "f"] = {
            ---@diagnostic disable-next-line: missing-parameter
            function()
              local window = {
                width = require("utils").size(vim.o.columns, 0.8),
                height = require("utils").size(vim.o.lines, 0.8),
                position = "center",
                enter = true,
              }
              vim.ui.select(
                {"console", "repl", "stacks", "breakpoints", "watches", "scopes" },
                {prompt = "Select Dap Element: ", default = "console" },
                function(select)
                  if select == "repl" then
                    require("dapui").float_element("repl", window)
                  elseif select == "stacks" then
                    require("dapui").float_element("stacks", window)
                  elseif select == "breakpoints" then
                    require("dapui").float_element("breakpoints", window)
                  elseif select == "watches" then
                    require("dapui").float_element("watches", window)
                  elseif select == "console" then
                    require("dapui").float_element("console", window)
                  elseif select == "scopes" then
                    require("dapui").float_element("scopes", window)
                  else
                    require("dapui").float_element("console", window)
                  end
                end
              )
            end,
            desc = "Open Dap UI Float Element",
          }
          maps.n[prefix_debug .. "d"] = {
            function() choose_dap_element() end,
            desc = "Switch dap ui element"
          }
          maps.n["<F9>"] = {
            function() require("persistent-breakpoints.api").toggle_breakpoint() end,
            desc = "Debugger: Toggle Breakpoint",
          }
          maps.n[prefix_debug .. "b"] = {
            function() require("persistent-breakpoints.api").toggle_breakpoint() end,
            desc = "Toggle Breakpoint (F9)",
          }
          maps.n[prefix_debug .. "B"] = {
            function() require("persistent-breakpoints.api").clear_all_breakpoints() end,
            desc = "Clear All Breakpoints",
          }
          maps.n[prefix_debug .. "C"] = {
            function() require("persistent-breakpoints.api").set_conditional_breakpoint() end,
            desc = "Conditional Breakpoint (S-F9)",
          }
          maps.n["<F21>"] = {
            function() require("persistent-breakpoints.api").set_conditional_breakpoint() end,
            desc = "Conditional Breakpoint (S-F9)",
          }
          maps.n[prefix_debug .. "S"] = {
            function() require("dap").run_to_cursor() end,
            desc = "Run To Cursor",
          }
          maps.n[prefix_debug .. "s"] = {
            function()
              local w = require "dap.ui.widgets"
              w.centered_float(w.sessions, {})
            end,
            desc = "Switch Debug Session",
          }
          maps.n[prefix_debug .. "G"] = {
            require("utils").create_launch_json,
            desc = "Create Dap Launch Json"
          }
          maps.n[prefix_debug .. "g"] = {
            function() vim.cmd [[DapShowLog]] end,
            desc = "Show Dap Log",
          }
          maps.n[prefix_debug .. "h"] = {
            function() require("dap.ui.widgets").hover()end,
            desc = "Debugger Hover",
          }
        end
      },
    },
    opts = {
      layout = {
        {
          elements = {
            { id = "console", size = 0.4 },
            { id = "scopes", size = 0.6 },
          },
          size = require("utils").size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "top" or "bottom"
        },
        {
          elements = {
            { id = "console", size = 1 },
          },
          size = require("utils").size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          elements = {
            { id = "repl", size = 1 },
          },
          size = require("utils").size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          elements = {
            { id = "stacks", size = 1 },
          },
          size = require("utils").size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          elements = {
            { id = "breakpoints", size = 1 },
          },
          size = require("utils").size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          elements = {
            { id = "watches", size = 1 },
          },
          size = require("utils").size(vim.o.lines, 0.3),
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          elements = {
            { id = "scopes", size = 1 }
          },
          size = require("utils").size(vim.o.lines, 0.3),
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
          size = require("utils").size(vim.o.columns, 0.2),
          position = "right",  -- can be "left" or right
        },
        {
          elements = {
            { id = "repl", size = 0.4 },
            { id = "console", size = 0.6 }
          },
          size = require("utils").size(vim.o.lines, 0.25),
          position = "bottom", --- can be "bottom" or "top"
        },
      },
      render = {
        max_type_length = 100, -- can be integer or nil
        max_value_lines = 100, -- can be integer or nil
        indent = 1,
      }
    },
    config = function(_, opts)
      local dapui =  require "dapui"
      dapui.setup(opts)
    end,
  }
}
