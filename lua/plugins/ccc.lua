return {
  {
    "uga-rosa/ccc.nvim",
    event = { "User AstroFile", "InsertEnter" },
    cmd = { "CccPick", "CccConvert", "CccHighlighterEnable", "CccHighlighterDisable", "CccHighlighterToggle" },
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings or {}
          maps.n["<M-c>"] = { "<Cmd>CccHighlighterToggle<CR>", desc = "Toggle colorizer" }
          maps.n["<M-m>"] = { "<Cmd>CccConvert<CR>", desc = "Convert color" }
          maps.i["<M-p>"] = { "<Cmd>CccPick<CR>", desc = "Pick Color" }
        end,
      },
    },
    opts = {
      highlighter = {
        auto_enable = true,
        lsp = true,
      },
    },
    config = function(_, opts)
      require("ccc").setup(opts)
      if opts.highlighter and opts.highlighter.auto_enable then vim.cmd.CccHighlighterEnable() end
    end,
  },
}
