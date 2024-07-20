local is_available = require("astrocore").is_available

---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      if not opts.mappings then opts.mappings = require("astrocore").empty_map_table() end
      local maps = opts.mappings
      if maps then
        -- telescope plugin mappings
        if is_available "telescope.nvim" then
          maps.n["<leader>fT"] = { "<cmd>TodoTelescope<cr>", desc = "Find TODOs" }
          maps.n["<Leader>fp"] = { "<cmd>Telescope projects<CR>", desc = "Switch Buffers In Telescope" }
          maps.n["<Leader>bt"] = {
            function()
              if #vim.t.bufs > 1 then
                require("telescope.builtin").buffers { sort_mru = true, ignore_current_buffer = true }
              else
                require("astrocore").notify "No other buffers open"
              end
            end,
            desc = "Switch Buffers In Telescope",
          }
        end
      end
      opts.mappings = maps
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
    },
    opts = function(_, opts)
      local actions = require "telescope.actions"

      return require("astrocore").extend_tbl(opts, {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          entry_prefix = "  ",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = nil,
          layout_strategy = nil,
          layout_config = {
            horizontal = {  prompt_position="bottom", preview_width = 0.55 },
          },
          vimgrep_arguments = {
            "rg",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!.git/",
            "--glob=!node_modules/",
            "--glob=!target/",
          },
          file_ignore_patterns = {},
          path_display = { "smart" },
          winblend = 0,
          border = {},
          borderchars = nil,
          color_devicons = true,
          set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil
        },
        pickers = {
          find_files = {
            -- dot file
            hidden = true,
          },
          live_grep = {
            --@usage don't include the filename in the search results
            only_sort_text = true,
          },
          grep_string = {
            only_sort_text = true,
          },
          planets = {
            show_pluto = true,
            show_moon = true,
          },
          git_files = {
            hidden = true,
            show_untracked = true,
          },
          colorscheme = {
            enable_preview = true,
          },
          buffers = {
            path_display = { "smart" },
            mappings = {
              i = { ["<C-d>"] = actions.delete_buffer + actions.move_to_top },
              n = { ["d"] = actions.delete_buffer + actions.move_to_top },
            },
          },
        },
      })
    end,
    config = function(...) require "astronvim.plugins.configs.telescope"(...) end,
  },
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      highlights = {
        -- set highlights for all themes
        -- use a function override to let us use lua to retrieve
        -- colors from highlight group there is no default table
        -- so we don't need to put a parameter for this function
        init = function()
          local get_hlgroup = require("astroui").get_hlgroup
          -- get highlights from highlight groups
          local normal = get_hlgroup "Normal"
          local fg, bg = normal.fg, normal.bg
          local bg_alt = get_hlgroup("WinBar").bg
          local green = get_hlgroup("String").fg
          local red = get_hlgroup("Error").fg
          -- return a table of highlights for telescope based on
          -- colors gotten from highlight groups
          return {
            TelescopeBorder = { fg = bg_alt, bg = bg },
            TelescopeNormal = { bg = bg },
            TelescopePreviewBorder = { fg = bg_alt, bg = bg },
            TelescopePreviewNormal = { bg = bg },
            TelescopePreviewTitle = { fg = bg, bg = green },
            TelescopePromptBorder = { fg = bg_alt, bg = bg },
            TelescopePromptNormal = { fg = fg, bg = bg },
            TelescopePromptPrefix = { fg = red, bg = bg },
            TelescopePromptTitle = { fg = bg, bg = red },
            TelescopeResultsBorder = { fg = bg, bg = bg },
            TelescopeResultsNormal = { bg = bg },
            TelescopeResultsTitle = { fg = bg, bg = bg },
            TelescopeSelection = { fg = bg, bg = bg_alt },
          }
        end,
      },
    },
  },
}
