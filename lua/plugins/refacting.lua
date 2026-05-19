return {
  "ThePrimeagen/refactoring.nvim",
  event = "VeryLazy",
  dependencies = {
    "lewis6991/async.nvim",
  },
  specs = {
    {
      "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
      ---@diagnostic disable: missing-fields
      ---@diagnostic disable: missing-parameter
      opts = function(_, opts)
        local maps = opts.mappings or {}
        local refactor = require("refactoring")
        maps.n["<Leader>lb"] = { function() refactor.refactor "Extract Block" end, desc = "Extract Block", }
        maps.n["<Leader>lB"] = { function() refactor.refactor "Extract Block To File" end, desc = "Extract Block To File", }
        maps.n["<Leader>lv"] = { function() refactor.refactor "Inline Variable" end, desc = "Inline Variable", }
        maps.n["<Leader>rp"] = { function() refactor.debug.printf { below = false } end, desc = "Debug: Print Function", }
        maps.n["<Leader>rc"] = { function() refactor.debug.cleanup {} end, desc = "Debug: Clean Up", }
        maps.n["<Leader>rd"] = { function() refactor.debug.print_var { below = false } end, desc = "Debug: Print Variable", }
        maps.x["<Leader>lm"] = { function() refactor.refactor "Extract Function" end, desc = "Extract Function", }
        maps.x["<Leader>lM"] = { function() refactor.refactor "Extract Function To File" end, desc = "Extract Function To File", }
        maps.x["<Leader>lv"] = { function() refactor.refactor "Extract Variable" end, desc = "Extract Variable", }
        maps.x["<Leader>li"] = { function() refactor.refactor "Inline Variable" end, desc = "Inline Variable", }
        maps.v["<Leader>lm"] = { function() refactor.refactor "Extract Function" end, desc = "Extract Function", }
        maps.v["<Leader>lM"] = { function() refactor.refactor "Extract Function To File" end, desc = "Extract Function To File", }
        maps.v["<Leader>lv"] = { function() refactor.refactor "Extract Variable" end, desc = "Extract Variable", }
        maps.v["<Leader>li"] = { function() refactor.refactor "Inline Variable" end, desc = "Inline Variable", }
        maps.v["<Leader>lb"] = { function() refactor.refactor "Extract Block" end, desc = "Extract Block", }
        maps.v["<Leader>lB"] = { function() refactor.refactor "Extract Block To File" end, desc = "Extract Block To File", }
        maps.v["<Leader>lR"] = { function() refactor.select_refactor() end, desc = "Select Refactor", }
        maps.v["<Leader>rp"] = { function() refactor.debug.printf { below = false } end, desc = "Debug: Print Function", }
        maps.v["<Leader>rc"] = { function() refactor.debug.cleanup {} end, desc = "Debug: Clean Up", }
        maps.v["<Leader>rd"] = { function() refactor.debug.print_var { below = false } end, desc = "Debug: Print Variable", }
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
