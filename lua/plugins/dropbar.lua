if vim.fn.has "nvim-0.10" == 0 then
  return {}
else
  return {
    { 
      "Bekaboo/dropbar.nvim", 
      event = "UIEnter", 
      opts = {
        icons = {
          ui = {
            bar = {
              separator = " > ",
              extends = ".."
            },
            menu = {
              separator = " ",
              indicator = " > "
            },
          },
        },
      },
    },
  }
end
