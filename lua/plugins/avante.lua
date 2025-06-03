local prefix = "<Leader>P"

---@type LazySpec
return {
  "yetone/avante.nvim",
  build = "make",
  event = "User AstroFile",
  cmd = {
    "AvanteAsk",
    "AvanteBuild",
    "AvanteEdit",
    "AvanteRefresh",
    "AvanteSwitchProvider",
    "AvanteChat",
    "AvanteToggle",
    "AvanteClear",
  },
  dependencies = {
    { "stevearc/dressing.nvim" },
    { "nvim-lua/plenary.nvim", lazy = true },
    { "MunifTanjim/nui.nvim", lazy = true },
  },
  opts = {
    providers = {
      deepseek = {
        __inherited_from = "openai",
        api_key_name = "DEEPSEEK_API_KEY",
        endpoint = "https://api.deepseek.com",
        model = "deepseek-coder",
        max_tokens = 1000
      },
    },
    file_selector = {
      provider = "fzf",
      provider_opts = {},
    },
    mappings = {
      ask = prefix .. "<CR>",
      edit = prefix .. "e",
      refresh = prefix .. "r",
      focus = prefix .. "f",
      toggle = {
        default = prefix .. "t",
        debug = prefix .. "d",
        hint = prefix .. "h",
        suggestion = prefix .. "s",
        repomap = prefix .. "R",
      },
      diff = {
        next = "]c",
        prev = "[c",
      },
      files = {
        add_current = prefix .. ".",
      },
    },
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        opts.mappings.n[prefix] = { desc = " Avante" }
        opts.options.opt.laststatus = 3
      end,
    },
    {
      'Exafunction/windsurf.vim',
      event = 'BufEnter',
      config = function ()
        -- Change '<C-g>' here to any keycode you like.
        vim.keymap.set('i', '<M-;>', function () return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
        vim.keymap.set('i', '<M-]>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
        vim.keymap.set('i', '<M-[>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
        vim.keymap.set('i', '<C-]>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })
      end
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      optional = true,
      opts = function(_, opts)
        if not opts.file_types then opts.file_types = { "markdown" } end
        opts.file_types = require("astrocore").list_insert_unique(opts.file_types, { "Avante" })
      end,
    },
    {
      "Saghen/blink.cmp",
      optional = true,
      opts = function(_, opts)
        if not opts.sources then opts.sources = {} end
        return require("astrocore").extend_tbl(opts, {
          sources = {
            compat = require("astrocore").list_insert_unique(
              opts.sources.compat or {},
              { "avante_commands", "avante_mentions", "avante_files" }
            ),
            providers = {
              avante_commands = {
                name = "AvanteCommands",
                score_offset = 90,
                async = true,
              },
              avante_files = {
                name = "AvanteFiles",
                score_offset = 100,
                async = true,
              },
              avante_mentions = {
                name = "AvanteMentions",
                score_offset = 1000,
                async = true,
              },
            },
          },
        })
      end,
    },
  },
}
