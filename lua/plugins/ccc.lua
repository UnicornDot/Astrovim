return {
  { "NvChad/nvim-colorizer.lua", enabled = false },
  {
    "uga-rosa/ccc.nvim",
    event = { "User AstroFile", "InsertEnter" },
    cmd = { "CccPick", "CccConvert", "CccHighlighterEnable", "CccHighlighterDisable", "CccHighlighterToggle" },
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["<M-c>"] = { "<Cmd>CccHighlighterToggle<CR>", desc = "Toggle colorizer" },
              ["<M-m>"] = { "<Cmd>CccConvert<CR>", desc = "Convert color" },
            },
            i = {
              ["<M-p>"] = { "<Cmd>CccPick<CR>", desc = "Pick Color" },
            }
          },
        },
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
