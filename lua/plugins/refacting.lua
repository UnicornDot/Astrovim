return {
  "ThePrimeagen/refactoring.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
      ---@diagnostic disable: missing-fields
      ---@diagnostic disable: missing-parameter
      opts = function(_, opts)
        return require("astrocore").extend_tbl(opts, {
          mappings = {
            n = {
              ["<Leader>le"] = {
                function() require("refactoring").refactor "Extract Block" end,
                desc = "Extract Block",
              },
              ["<Leader>lv"] = {
                function() require("refactoring").refactor "Inline Variable" end,
                desc = "Inline Variable",
              },
              ["<Leader>rp"] = {
                function() require("refactoring").debug.printf { below = false } end,
                desc = "Debug: Print Function",
              },
              ["<Leader>rc"] = {
                function() require("refactoring").debug.cleanup {} end,
                desc = "Debug: Clean Up",
              },
              ["<Leader>rd"] = {
                function() require("refactoring").debug.print_var { below = false } end,
                desc = "Debug: Print Variable",
              },
              ["<Leader>lb"] = {
                function() require("refactoring").refactor "Extract Block To File" end,
                desc = "Extract Block To File",
              },
            },
            x = {
              ["<Leader>le"] = {
                function() require("refactoring").refactor "Extract Function" end,
                desc = "Extract Function",
              },
              ["<Leader>lm"] = {
                function() require("refactoring").refactor "Extract Function To File" end,
                desc = "Extract Function To File",
              },
              ["<Leader>lv"] = {
                function() require("refactoring").refactor "Extract Variable" end,
                desc = "Extract Variable",
              },
              ["<Leader>li"] = {
                function() require("refactoring").refactor "Inline Variable" end,
                desc = "Inline Variable",
              },
            },
            v = {
              ["<Leader>le"] = {
                function() require("refactoring").refactor "Extract Function" end,
                desc = "Extract Function",
              },
              ["<Leader>lm"] = {
                function() require("refactoring").refactor "Extract Function To File" end,
                desc = "Extract Function To File",
              },
              ["<Leader>lv"] = {
                function() require("refactoring").refactor "Extract Variable" end,
                desc = "Extract Variable",
              },
              ["<Leader>li"] = {
                function() require("refactoring").refactor "Inline Variable" end,
                desc = "Inline Variable",
              },
              ["<Leader>lb"] = {
                function() require("refactoring").refactor "Extract Block" end,
                desc = "Extract Block",
              },
              ["<Leader>lB"] = {
                function() require("refactoring").refactor "Extract Block To File" end,
                desc = "Extract Block To File",
              },
              ["<Leader>lR"] = {
                function() require("refactoring").select_refactor() end,
                desc = "Select Refactor",
              },
              ["<Leader>rp"] = {
                function() require("refactoring").debug.printf { below = false } end,
                desc = "Debug: Print Function",
              },
              ["<Leader>rc"] = {
                function() require("refactoring").debug.cleanup {} end,
                desc = "Debug: Clean Up",
              },
              ["<Leader>rd"] = {
                function() require("refactoring").debug.print_var { below = false } end,
                desc = "Debug: Print Variable",
              },
            },
          },
        } --[[@as AstroCoreOpts]])
      end,
    },
  },
  opts = {
    prompt_func_return_type = {
      go = true,
    },
    prompt_func_param_type = {
      go = true,
    },
  },
}
