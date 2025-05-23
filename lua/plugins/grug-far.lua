---@type LazySpec
return {
  "MagicDuck/grug-far.nvim",
  cmd = "GrugFar",
  specs = {
    {
      "AstroNvim/astroui",
      ---@type AstroUIOpts
      opts = {
        icons = {
          GrugFar = "󰛔",
        },
      },
    },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings or {}
        local prefix = "<Leader>s"

        maps.n[prefix .. "r"] = {
          function()
            local file_path = vim.fn.expand "%:p"
            local file_name = vim.fn.fnamemodify(file_path, ":t")
            require("grug-far").open { prefills = { search = vim.fn.expand "<cword>", filesFilter = file_name } }
          end,
          desc = "Search and Replace",
        }
        maps.v[prefix .. "r"] = {
          function()
            local is_visual = vim.fn.mode():lower():find "v"
            if is_visual then -- needed to make visual selection work
              vim.cmd [[normal! v]]
            end
            local grug = require "grug-far"
            local file_path = vim.fn.expand "%:p"
            local file_name = vim.fn.fnamemodify(file_path, ":t");

            (is_visual and grug.with_visual_selection or grug.grug_far) {
              prefills = { filesFilter = file_name },
            }
          end,
          desc = "Search and Replace (selected)",
        }
      end,
    },
    {
      "zbirenbaum/copilot.lua",
      optional = true,
      opts = {
        filetypes = {
          ["grug-far"] = false,
          ["grug-far-history"] = false,
        },
      },
    },
  },
  dependencies = {
    "echasnovski/mini.icons",
  },
  ---@param opts GrugFarOptionsOverride
  -- NOTE: Wrapping opts into a function, because `astrocore` can set vim options
  opts = function(_, opts)
    if not opts.icons then opts.icons = {} end
    opts.icons.enabled = vim.g.icons_enabled
    if not vim.g.icons_enabled then
      opts.resultsSeparatorLineChar = "-"
      opts.spinnerStates = {
        "|",
        "\\",
        "-",
        "/",
      }
    end
    return vim.tbl_deep_extend("force", opts, {
      headerMaxWidth = 80,
      icons = {
        enabled = vim.g.icons_enabled,
        fileIconsProvider = "mini.icons"
      },
      keymaps = {
        replace = { n = "<LocalLeader>r" },
        qflist = { n = "<LocalLeader>c" },
        syncLocations = { n = "<LocalLeader>s" },
        syncLine = { n = "<LocalLeader>l" },
        close = { n = "q" },
        historyOpen = { n = "<LocalLeader>t" },
        historyAdd = { n = "<LocalLeader>a" },
        refresh = { n = "<LocalLeader>f" },
        openLocation = { n = "<LocalLeader>o" },
        gotoLocation = { n = "<enter>" },
        pickHistoryEntry = { n = "<enter>" },
        abort = { n = "<LocalLeader>b" },
        help = { n = "g?" },
        toggleShowRgCommand = { n = "<LocalLeader>p" },
      },
      startInInsertMode = false,
    } --[[@as GrugFarOptionsOverride]])
  end,
}
