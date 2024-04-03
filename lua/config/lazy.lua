local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.g.astronvim_first_install = true -- lets AstroNvim know that this is an initial installation
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup {
  ui = {
    width = 0.8,
    height = 0.8,
    border = "rounded"
  },
  spec = {
    -- TODO: change `branch="v4"` to `version="^4"` on release
    { "AstroNvim/AstroNvim", branch = "main", import = "astronvim.plugins" },
    -- AstroCommunity: import any community modules here
    -- TODO: Remove branch v4 on release
    -- { "AstroNvim/astrocommunity", branch = "v4" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  install = { colorscheme = { "catppuccin" } },
  performance = {
    rtp = {
      -- disable some rtp plugins, add more to your liking
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
      },
    },
  },
}
