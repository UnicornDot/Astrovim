return { 'gen740/SmoothCursor.nvim',
  opts = {
  },
  config = function()
    require('smoothcursor').setup({
      cursor = "󰁕",
      fancy = {
        enable = true,
        head = { cursor = "󱓟", texthl = "SmoothCursor", linehl = nil },
      },
      disable_float_win = true,
      disabled_filetypes = { "neo-tree", "lazy"},
    })
  end
}
