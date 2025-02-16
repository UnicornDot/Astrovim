local utils = require "utils"

-- @type LazySpec
return {
  "AstroNvim/astrocore",
  version = false,
  branch = "v2",
  ---@type AstroCoreOpts
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
      },
      g = {
        -- resession_enabled = false,
        -- transparent_background = true,
        autoformat = false,
      }
    }

    if vim.fn.has "nvim-0.10" == 1 then
      options.opt.smoothscroll = true
      options.opt.foldexpr = "v:lua.require'ui'.foldexpr()"
      options.opt.foldmethod = "expr"
      options.opt.foldtext = ""
    else
      options.opt.foldmethod = "indent"
      options.opt.foldtext = "v:lua.require'ui'.foldtext()"
    end

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
        large_buf = { size = 1024 * 1024 * 1.5, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
        autopairs = false, -- enable autopairs at start
        cmp = false, -- enable completion at start
        diagnostics_mode = 3, -- diagnostics_mode on start (0 = off, 1 = no sign/virtual text, 2 = no virtual text, 3 = on)
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
      autocmds = {
        auto_spell = {
          {
            event = "FileType",
            desc = "Enable wrap and spell for text like documents",
            pattern = { "gitcommit", "markdown", "text", "plaintex" },
            callback = function()
              vim.opt_local.wrap = true
              vim.opt_local.spell = true
            end,
          },
        },
        auto_hide_tabline = {
          {
            event = "User",
            desc = "Auto hide tabline",
            pattern = "AstroBufsUpdated",
            callback = function()
              local new_showtabline = #vim.t.bufs > 1 and 2 or 1
              if new_showtabline ~= vim.opt.showtabline:get() then vim.opt.showtabline = new_showtabline end
            end,
          },
        },
        auto_conceallevel_for_json = {
          {
            event = "FileType",
            desc = "Fix conceallevel for json files",
            pattern = { "json", "jsonc" },
            callback = function()
              vim.wo.spell = false
              vim.wo.conceallevel = 0
            end,
          },
        },
        auto_close_dadbod_output = {
          {
            event = "FileType",
            pattern = { "dbout"},
            callback = function(event)
              vim.bo[event.buf].buflisted = false
              vim.schedule(function()
                vim.keymap.set("n", "q", function() vim.cmd "q!" end, {
                  buffer = event.buf,
                  silent = true,
                  desc = "Quit buffer",
                })
              end)
            end,
          },
        },
        auto_select_virtualenv = {
          {
            event = "VimEnter",
            desc = "Auto select virtualenv Nvim open",
            pattern = "*",
            callback = function()
              local venv = vim.fn.findfile("pyproject.toml", vim.fn.getcwd() .. ";")
              if venv ~= "" then require("venv-selector").retrieve_from_cache() end
            end,
            once = true,
          },
        },
      },
    })
  end,
}
