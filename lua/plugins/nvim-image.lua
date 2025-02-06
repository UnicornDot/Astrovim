return {
  "3rd/image.nvim",
  cond = require("lazy_load_util").wants {
    ft = { "markdown","markdown.mdx", "norg", "vimwiki" },
    root = "README.md",
  },
  ft = { "markdown","markdown.mdx", "norg", "vimwiki" },
  depencencies = {
    {
      "nvim-treesitter/nvim-treesitter",
      optional = true,
      opts = function(_, opts)
        if opts.ensure_installed ~= "all" then
          opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "markdown", "markdown_inline" })
        end
      end,
    },
    {
      -- luarocks.nvim is a Neovim plugin designed to streamline the installation
      -- of luarocks packages directly within Neovim. It simplifies the process
      -- of managing Lua dependencies, ensuring a hassle-free experience for
      -- Neovim users.
      -- https://github.com/vhyrro/luarocks.nvim
      "vhyrro/luarocks.nvim",
      -- this plugin needs to run before anything else
      priority = 1001,
      opts = {
        rocks = { "magick" },
      },
    },
  },
  opts = {
    backend = "kitty",
    processor = "magick_rock",
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = true,
        download_remote_images = true,
        only_render_image_at_cursor = true,
        filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
      },
      neorg = {
        enabled = true,
        clear_in_insert_mode = true,
        download_remote_images = true,
        only_render_image_at_cursor = true,
        filetypes = { "norg" },
      },
    },
    max_width = 100,
    max_height = 12,
    max_height_window_percentage = math.huge,
    max_width_window_percentage = math.huge,

    window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
    window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    editor_only_render_when_focused = true, -- auto show/hide images when the editor gains/looses focus
    tmux_show_only_in_active_window = true, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
    hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" }, -- render image files as images when opened
  },
}
