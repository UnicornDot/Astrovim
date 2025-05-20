return {
  { "max397574/better-escape.nvim", enabled = false },
  { "jay-babu/mason-null-ls.nvim", enabled = false },
  { "nvimtools/none-ls.nvim", enabled = false },
  { "NMAC427/guess-indent.nvim", enabled = false },
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
            { icon = "󱛊 ", key = "p", desc = "Find Project", action = ":lua Snacks.dashboard.pick('projects')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = "󰯃 ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = "󱘢 ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = "󰢚 ", key = "s", desc = "Restore Session", section = "session" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
          header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        },
        sections = {
          {section = "header", gap = 1, padding = 1 },
          {section = "keys", gap = 1, padding = 1 },
          {section = "startup", gap = 1, padding  = 1 },
          {
              section = "terminal",
              cmd = "bat -pp " .. vim.fn.stdpath("config") .. "/bar.txt",
              random = 10,
              pane = 2,
              indent = 0,
              height = 30,
              -- icon = "🔖", indent = 3, padding = 1, 
          },
        }
      },
      picker = {},
      image = {},
      quickfile = { enabled = true },
      indent = { enabled = true },
      input = {
        enabled = true
      },
      scroll = { enabled = true },
      words = { enabled = true },
      rename = { enabled = true },
      debug = { enabled = true },
      lazygit =  {},
      terminal = {},
      profiler = { enabled = true }
    },
    keys = {
      { "<Leader>;", function() Snacks.dashboard() end, desc = "Dashboard"}
    },
  }
}
