return {
  "rachartier/tiny-code-action.nvim",
  dependencies = {
      {
        "folke/snacks.nvim",
        opts = {
          terminal = {},
        }
      }
  },
  event = "LspAttach",
  opts = {},
  specs = {
    {
      "AstroNvim/astrolsp",
      optional = true,
      opts = function(_, opts)
          local maps = opts.mappings or {}
          maps.n["<Leader>la"] = {
            function() require("tiny-code-action").code_action() end,
            desc = "Lsp Code Action",
            silent = true
          }
          maps.x["<Leader>la"] = {
            function() require("tiny-code-action").code_action() end,
            desc = "Lsp Code Action"
          }
        end
    }
  }
}
