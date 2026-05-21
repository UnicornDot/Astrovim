-- Customize Treesitter
-- --------------------
-- Treesitter customizations are handled with AstroCore
-- as nvim-treesitter simply provides a download utility for parsers

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    treesitter = {
      highlight = true,    -- enable/disable treesitter based highlighting
      indent = true,       -- enable/disable treesitter based indentation
      auto_install = true, -- enable/disable automatic installation of detected languages
      ensure_installed = {
        "lua",
        "luap",
        "vim",
        "vimdoc",
        -- add more arguments for adding more treesitter parsers
        "python",
        "json",
        "jsonc",
        "json5",
        "typescript",
        "tsx",
        "javascript",
        "jsx",
        "jsdoc",
        "html",
        "css",
        "scss",
        "markdown",
        "markdown_inline",
        "bash",
        "java",
        "yaml",
        "toml",
        "rust",
        "rst",
        "c",
        "cpp",
        "objc",
        "cuda",
        "proto",
        "qmljs",
        "go",
        "gomod",
        "gowork",
        "gosum",
        "goctl",
        "ruby",
        "awk",
        "dockerfile",
        "kotlin",
        "groovy",
        "xml",
        "ninja",
        "vue",
        "yuck",
        "zig",
        "vimdoc",
        "swift",
        "sql",
        "regex",
        "prisma",
        "nginx",
        "kdl",
        "properties",
        "ini",
        "latex",
        "make",
        "cmake",
        "dart",
        "desktop",
        "gitignore",
        "asm",
        'ron',
        "thrift",
        "svelte",
        "typst"
      },
    },
  },
}
