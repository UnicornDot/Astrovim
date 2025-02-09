return {
  { "max397574/better-escape.nvim", enabled = false },
  { "kevinhwang91/nvim-ufo", enabled = false},
  { "jay-babu/mason-null-ls.nvim", enabled = false },
  { "nvimtools/none-ls.nvim", enabled = false },
  { "goolord/alpha-nvim", enabled = false },
  { "lukas-reineke/indent-blankline.nvim", enabled = false },
  { "rcarriga/nvim-notify", enabled = false },
  { "NMAC427/guess-indent.nvim", enabled = false },
  { "rebelot/heirline.nvim", opts = function(_, opts) opts.statuscolumn = false end },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      notifier = { enabled = true, timeout=3000 },
      dashboard = {
        enabled = true,
        row = nil,
        col = nil,
        width = 50,
        preset = {
          keys = {
            { icon = "󱛊 ", key = "p", desc = "Find Project", action = ":FzfLua grep_project" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = "󰯃 ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = "󱘢 ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = "󰢚 ", key = "s", desc = "Restore Session", section = "session" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          }
        },
        sections = {
          {section = "header", gap = 1, padding = 1 },
          {section = "keys", gap = 1, padding = 1 },
          {section = "startup", gap = 1, padding  = 1 },
          {
              section = "terminal",
              cmd = "bat -p " .. vim.fn.stdpath("config") .. "/bar.txt",
              random = 10,
              pane = 2,
              indent = 0,
              height = 30,
              -- icon = "🔖", indent = 3, padding = 1, 
          },
        }
      },
      quickfile = { enabled = true },
      statuscolumn = {
        enabled = true,
        left = { "mark", "sign" }, -- priority of signs on the left (high to low)
        right = { "fold", "git" }, -- priority of signs on the right (high to low)
        folds = {
          open = false, -- show open fold icons
          git_hl = false, -- use Git Signs hl for fold icons
        },
        git = {
          -- patterns to match Git signs
          patterns = { "GitSign", "MiniDiffSign" },
        },
        refresh = 50, -- refresh at most every 50ms
      },
      indent = { enabled = true },
      input = { enabled = true },
      scroll = { enabled = true },
      words = { enabled = true },
      rename = { enabled = true },
      debug = { enabled = true },
      lazygit =  {},
      terminal = {},
      profiler = { enabled = true }
    },
  }
}
