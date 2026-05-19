return {
  {
    "nvim-neotest/neotest",
    lazy = true,
    specs = {
      {"nvim-lua/plenary.nvim", lazy = true },
      { "nvim-neotest/nvim-nio", lazy = true },
      {
        "AstroNvim/astroui",
        opts = {
          icons = {
            Tests = "󰗇",
            Watch = "",
          }
        }
      },
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings

          local get_file_path = function() return vim.fn.expand "%" end
          local get_project_path = function() return vim.fn.getcwd() end
          local neotest = require("neotest")
          local astroui = require("astroui")

          local prefix = "<Leader>T"

          maps.n[prefix] = { desc = astroui.get_icon("Tests", 1, true) .. "Tests", }
          maps.n[prefix .. "t"] = { function() neotest.run.run() end, desc = "Run test", }
          maps.n[prefix .. "d"] = { function() neotest.run.run { strategy = "dap" } end, desc = "Debug test", }
          maps.n[prefix .. "f"] = { function() neotest.run.run(get_file_path()) end, desc = "Run all tests in file", }
          maps.n[prefix .. "p"] = { function() neotest.run.run(get_project_path()) end, desc = "Run all tests in project", }
          maps.n[prefix .. "<cr>"] = { function() neotest.summary.toggle() end, desc = "Test Summary", }
          maps.n[prefix .. "o"] = { function() neotest.output.open() end, desc = "Output hover", }
          maps.n[prefix .. "O"] = { function() neotest.output_panel.toggle() end, desc = "Output window", }
          maps.n["]T"] = { function() neotest.jump.next() end, desc = "Next test", }
          maps.n["[T"] = { function() neotest.jump.prev() end, desc = "Previous test", }

          local watch = prefix .. "w"

          maps.n[watch] = { desc = astroui.get_icon("Watch", 1, true) .. "Watch", }
          maps.n[watch .. "t"] = { function() neotest.watch.toggle() end, desc = "Toggle watch test", }
          maps.n[watch .. "f"] = { function() neotest.watch.toggle(get_file_path()) end, desc = "Toggle watch all test in file", }
          maps.n[watch .. "p"] = { function() neotest.watch.toggle(get_project_path()) end, desc = "Toggle watch all tests in project", }
          maps.n[watch .. "s"] = { function() neotest.watch.stop() end, desc = "Stop all watches", }
        end,
      },
    },
    config = function(_, opts)
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, vim.api.nvim_create_namespace "neotest")
      require("neotest").setup(opts)
    end,
    opts = {
      status = { virtual_text = true },
      output = { open_on_run = true },
    },
  },
}
