return {
  "ThePrimeagen/refactoring.nvim",
  event = "VeryLazy",
  specs = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
      ---@diagnostic disable: missing-fields
      ---@diagnostic disable: missing-parameter
      opts = function(_, opts)
        local maps = opts.mappings or {}
        maps.n["<Leader>lb"] = {
          function() require("refactoring").refactor "Extract Block" end,
          desc = "Extract Block",
        }
        maps.n["<Leader>lB"] = {
          function() require("refactoring").refactor "Extract Block To File" end,
          desc = "Extract Block To File",
        }
        maps.n["<Leader>lv"] = {
          function() require("refactoring").refactor "Inline Variable" end,
          desc = "Inline Variable",
        }
        maps.n["<Leader>rp"] = {
          function() require("refactoring").debug.printf { below = false } end,
          desc = "Debug: Print Function",
        }
        maps.n["<Leader>rc"] = {
          function() require("refactoring").debug.cleanup {} end,
          desc = "Debug: Clean Up",
        }
        maps.n["<Leader>rd"] = {
          function() require("refactoring").debug.print_var { below = false } end,
          desc = "Debug: Print Variable",
        }
        maps.x["<Leader>lm"] = {
          function() require("refactoring").refactor "Extract Function" end,
          desc = "Extract Function",
        }
        maps.x["<Leader>lM"] = {
          function() require("refactoring").refactor "Extract Function To File" end,
          desc = "Extract Function To File",
        }
        maps.x["<Leader>lv"] = {
          function() require("refactoring").refactor "Extract Variable" end,
          desc = "Extract Variable",
        }
        maps.x["<Leader>li"] = {
          function() require("refactoring").refactor "Inline Variable" end,
          desc = "Inline Variable",
        }
        maps.v["<Leader>lm"] = {
          function() require("refactoring").refactor "Extract Function" end,
          desc = "Extract Function",
        }
        maps.v["<Leader>lM"] = {
          function() require("refactoring").refactor "Extract Function To File" end,
          desc = "Extract Function To File",
        }
        maps.v["<Leader>lv"] = {
          function() require("refactoring").refactor "Extract Variable" end,
          desc = "Extract Variable",
        }
        maps.v["<Leader>li"] = {
          function() require("refactoring").refactor "Inline Variable" end,
          desc = "Inline Variable",
        }
        maps.v["<Leader>lb"] = {
          function() require("refactoring").refactor "Extract Block" end,
          desc = "Extract Block",
        }
        maps.v["<Leader>lB"] = {
          function() require("refactoring").refactor "Extract Block To File" end,
          desc = "Extract Block To File",
        }
        maps.v["<Leader>lR"] = {
          function() require("refactoring").select_refactor() end,
          desc = "Select Refactor",
        }
        maps.v["<Leader>rp"] = {
          function() require("refactoring").debug.printf { below = false } end,
          desc = "Debug: Print Function",
        }
        maps.v["<Leader>rc"] = {
          function() require("refactoring").debug.cleanup {} end,
          desc = "Debug: Clean Up",
        }
        maps.v["<Leader>rd"] = {
          function() require("refactoring").debug.print_var { below = false } end,
          desc = "Debug: Print Variable",
        }
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
