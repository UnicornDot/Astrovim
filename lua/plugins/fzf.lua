local function symbols_filter(entry, ctx)
  if ctx.symbols_filter == nil then ctx.symbols_filter = require("utils").get_kind_filter(ctx.bufnr) or false end
  if ctx.symbols_filter == false then return true end
  return vim.tbl_contains(ctx.symbols_filter, entry.kind)
end

local astrocore = require("astrocore")

return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  specs = {
    {
      "AstroNvim/astrolsp",
      optional = true,
      opts = function(_, opts)
        if astrocore.is_available "fzf-lua" then
          local maps = opts.mappings or {}
          maps.n["<Leader>lX"] = {
            function() require("fzf-lua").diagnostics_document() end,
            desc = "Search diagnostics"
          }
          maps.n["<Leader>lS"] = {
            function()
              require("fzf-lua").lsp_live_workspace_symbols {
                regex_filter = symbols_filter,
              }
            end,
            desc = "Goto Symbol (Workspace)"
          }
        end
      end,
    },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings or {}
        maps.n["<Leader>f"] = vim.tbl_get(opts, "_map_sections", "f")

        maps.n["<Leader>fx"] = { "<cmd>FzfLua diagnostics_document<cr>", desc = "Find Document Diagnostics" }
        maps.n["<Leader>fX"] = { "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Find Workspace Diagnostics" }
        maps.n["<Leader>fa"] = { "<cmd>FzfLua autocmds<cr>", desc = "Find autocmds" }
        maps.n["<Leader>fq"] = { "<cmd>FzfLua quickfix<cr>", desc = "Find Quickfix" }
      end,
    },
  },
  dependencies = {
    "nvim-mini/mini.icons"
  },
  opts = function()
    local config = require "fzf-lua.config"
    local actions = require "fzf-lua.actions"
    -- Quickfix
    config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
    config.defaults.keymap.fzf["ctrl-u"] = "preview-page-up"
    config.defaults.keymap.fzf["ctrl-d"] = "preview-page-down"
    config.defaults.keymap.builtin["<c-u>"] = "preview-page-up"
    config.defaults.keymap.builtin["<c-d>"] = "preview-page-down"
    config.defaults.keymap.fzf["ctrl-x"] = "jump"
    config.defaults.keymap.fzf["ctrl-f"] = "half-page-down"
    config.defaults.keymap.fzf["ctrl-b"] = "half-page-up"

    -- Trouble
    if astrocore.is_available("trouble.nvim") then
      config.defaults.actions.files["ctrl-t"] = require("trouble.sources.fzf").actions.open
    end

    -- diffview
    if astrocore.is_available("diffview.nvim") then
      config.defaults.git.commits.actions["ctrl-r"] = function(selected, _)
        local commit_hash = selected[1]:match("[^ ]+")
        vim.cmd.DiffviewOpen { commit_hash }
      end
      config.defaults.git.bcommits.actions["ctrl-r"] = function(selected, _)
        local commit_hash = selected[1]:match("[^ ]+")
        vim.cmd.DiffviewOpen { commit_hash }
      end
      config.defaults.git.branches.actions["ctrl-r"] = function(selected, _)
        local branch = selected[1]:match("[^%s%*]+")
        vim.cmd.DiffviewOpen { branch }
      end
    end

    local img_previewer ---@type string[]?
    for _, v in ipairs {
      { cmd = "ueberzug", args = {} },
      { cmd = "chafa",    args = { "{file}", "--format=symbols" } },
      { cmd = "viu",      args = { "-b" } },
    } do
      if vim.fn.executable(v.cmd) == 1 then
        img_previewer = vim.list_extend({ v.cmd }, v.args)
        break
      end
    end
    return {
      "default-title",
      fzf_colors = true,
      fzf_opts = {
        ["--no-scrollbar"] = true,
        ["--layout"] = "default",
      },
      defaults = {
        -- formatter = "path.filename_first",
        formatter = "path.dirname_first",
      },
      previewers = {
        builtin = {
          extensions = {
            ["png"] = img_previewer,
            ["jpg"] = img_previewer,
            ["jpeg"] = img_previewer,
            ["gif"] = img_previewer,
            ["webp"] = img_previewer,
          },
          ueberzug_scaler = "fit_contain",
        },
      },
      ui_select = function(fzf_opts, items)
        return vim.tbl_deep_extend("force", fzf_opts, {
          prompt = " ",
          winopts = {
            title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
            title_pos = "center",
          },
        }, fzf_opts.kind == "codeaction" and {
          winopts = {
            layout = "vertical",
            -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
            height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5) + 16,
            width = 0.5,
            preview = not vim.tbl_isempty(require("utils").get_clients { bufnr = 0, name = "vtsls" }) and {
              layout = "vertical",
              vertical = "down:15,border-top",
              hidden = "hidden",
            } or {
              layout = "vertical",
              vertical = "down:15,border-top",
            },
          },
        } or {
          winopts = {
            width = 0.5,
            -- height is number of items, with a max of 80% screen height
            height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
          },
        })
      end,
      winopts = {
        width = 0.9,
        height = 0.9,
        row = 0.5,
        col = 0.5,
        preview = {
          scrollchars = { "┃", "" },
        },
      },
      files = {
        cwd_prompt = false,
        actions = {
          ["alt-i"] = { actions.toggle_ignore },
          ["ctrl-z"] = { actions.toggle_hidden },
        },
      },
      grep = {
        actions = {
          ["alt-i"] = { actions.toggle_ignore },
          ["ctrl-z"] = { actions.toggle_hidden },
        },
      },
      lsp = {
        symbols = {
          symbol_hl = function(s) return "TroubleIcon" .. s end,
          symbol_fmt = function(s) return s:lower() .. "\t" end,
          child_prefix = false,
        },
        code_actions = {
          previewer = vim.fn.executable "delta" == 1 and "codeaction_native" or nil,
        },
      },
    }
  end,
  config = function(_, opts)
    if opts[1] == "default-title" then
      -- use the same prompt for all pickers for profile `default-title` and
      -- profiles that use `default-title` as base profile
      local function fix(t)
        t.prompt = t.prompt ~= nil and " " or nil
        for _, v in pairs(t) do
          if type(v) == "table" then fix(v) end
        end
        return t
      end
      opts = vim.tbl_deep_extend("force", fix(require "fzf-lua.profiles.default-title"), opts)
      opts[1] = nil
    end
    require("fzf-lua").setup(opts)
  end,
  init = function()
    require("utils").on_very_lazy(function()
      vim.ui.select = function(...)
        require("lazy").load { plugins = { "fzf-lua" } }
        local opts = astrocore.plugin_opts "fzf-lua" or {}
        require("fzf-lua").register_ui_select(opts.ui_select or nil)
        return vim.ui.select(...)
      end
    end)
  end,
  keys = {
    { "<c-j>", "<c-j>", ft = "fzf", mode = "t", nowait = true },
    { "<c-k>", "<c-k>", ft = "fzf", mode = "t", nowait = true },
  },
}
