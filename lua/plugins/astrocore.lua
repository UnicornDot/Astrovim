local utils = require "utils"

-- @type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type function
  ---@diagnostic disable-next-line: assign-type-mismatch
  opts = function(_, opts)
    local mappings = require("keymapping").core_mappings(opts.mappings)
    local options = {
      opt = {
        conceallevel = 2, -- enable conceal
        concealcursor = "",
        list = false, -- show whitespace characters
        listchars = { tab = "│→", extends = "⟩", precedes = "⟨", trail = "·", nbsp = "␣" },
        showbreak = "↪ ",
        splitkeep = "screen",
        swapfile = false,
        wrap = false, -- soft wrap lines
        scrolloff = 8, -- keep 3 lines when scrolling
        winwidth = 10,
        winminwidth = 10,
        equalalways = false,
        autoread = true -- Required for `opts.events.reload`
      },
      g = {
        -- resession_enabled = false,
        -- transparent_background = true,
        autoformat = false,
      }
    }
    return vim.tbl_deep_extend( "force", opts, {
      -- Configure project root detection, check status with `:AstroRootInfo`
      diagnostics = {
        virtual_text = {
          prefix = "",
        },
        underline = false,
        update_in_insert = false,
      },
      -- modify core features of AstroNvim
      features = {
        large_buf = { size = 1024 * 1024, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
        autopairs = false, -- enable autopairs at start
        cmp = true, -- enable completion at start
        diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
        highlighturl = true, -- highlight URLs at start
        notifications = true, -- enable notifications at start
      },
      options = options,
      mappings = mappings,
      filetypes = {
        extension = {
          mdx = "markdown.mdx",
          qmd = "markdown",
          yml = utils.yaml_ft,
          yaml = utils.yaml_ft,
          json = "jsonc",
          api = "goctl",
          MD = "markdown",
          tpl = "gotmpl",
        },
        filename = {
          [".eslintrc.json"] = "jsonc",
          ["vifmrc"] = "vim",
        },
        pattern = {
          ["/tmp/neomutt.*"] = "markdown",
          ["tsconfig*.json"] = "jsonc",
          [".*/%.vscode/.*%.json"] = "jsonc",
          [".*/waybar/.*/config"] = "jsonc",
          [".*/make/config"] = "dosini",
          [".*/kitty/.+%.conf"] = "ketty",
          [".*/hypr/.+%.conf"] = "hyprlang",
          ["%.env%.[%W_.-]+"] = "sh",
        },
      },
    })
  end,
}
