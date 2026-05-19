---@type LazySpec
return {
  "barrett-ruth/live-server.nvim",
  lazy = true,
  build = "npm install -g live-server",
  cmd = { "LiveServerStart", "LiveServerStop" },
  opts = {},
  specs = {
    {
      "AstroNvim/astrocore",
      optional = true,
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["<Leader>lw"] = { "<Cmd>LiveServerStart<CR>", desc = "Start Live Server" }
        maps.n["<Leader>lW"] = { "<Cmd>LiveServerStop<CR>", desc = "Stop Live Server" }
      end,
    },
  },
}
