local astrocore = require("astrocore")
local prefix_diff = "<Leader>g"

---@type LazySpec
return {
  "sindrets/diffview.nvim",
  event = "User AstroGitFile",
  cmd = { "DiffviewOpen" },
  lazy = true,
  specs = {
    {
      ---@type AstroCoreOpts
      "AstroNvim/astrocore",
      optional = true,
      opts = function(_, opts)
        local maps = opts.mappings
        if vim.fn.executable "git" == 1 then
          maps.n[prefix_diff .. "o"] = { function() vim.cmd [[DiffviewOpen]] end, desc = "Open Git Diffview", }
          maps.n[prefix_diff .. "H"] = { function() vim.cmd [[DiffviewFileHistory]] end, desc = "Open current branch git history", }
          maps.n[prefix_diff .. "h"] = { function() vim.cmd [[DiffviewFileHistory %]] end, desc = "Open current file git history", }
        end
      end,
    },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      default = { winbar_info = false, disable_diagnostic = true },
      file_history = { winbar_info = false, disable_diagnostic = true },
    },
    file_panel = {
      win_config = { -- see | diffview-config-win_config
        position =   "bottom",
        height =  require("utils").size(vim.o.lines, 0.25),
      },
    },
    hooks = {
      view_enter = function()
        astrocore.set_mappings {
          n = {
            [prefix_diff .. "d"] = {
              function() vim.cmd [[DiffviewClose]] end,
              desc = "Close Git Diffview",
            }
          }
        }
      end,
      view_leave = function()
        astrocore.set_mappings {
          n = {
            [prefix_diff .. "d"] = {
              function() vim.cmd [[DiffviewOpen]] end,
              desc = "Open Git Diffview",
            }
          }
        }
      end,
    },
  },
}
