return { 'gen740/SmoothCursor.nvim',
  opts = {
  },
  config = function()
    require('smoothcursor').setup({
      cursor = "󰁕",
      fancy = {
        enable = true,
        head = { cursor = "󱓟", texthl = "SmoothCursor", linehl = nil },
      }
    })
  end
}
