local open = function(command, opts)
  opts = opts or {}
  if opts.cmd == nil and command == "git_files" and opts.show_untracked then
    opts.cmd = "git ls-files --exclude-standard --cached --others"
  end
  return require("fzf-lua")[command](opts)
end

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
    { "nvim-telescope/telescope.nvim", optional = true, enabled = false },
    { "nvim-telescope/telescope-fzf-native.nvim", optional = true, enabled = false },
    { "stevearc/dressing.nvim", optional = true, enabled = false },
    {
      "AstroNvim/astrolsp",
      optional = true,
      opts = function(_, opts)
        if astrocore.is_available "fzf-lua" then
          local maps = opts.mappings or {}
          maps.n.gd = {
            "<cmd>FzfLua lsp_definitions jump_to_single_result=true ignore_current_line=true<cr>", 
            desc = "Goto Definition"
          }
          maps.n.gy = {
            "<cmd>FzfLua lsp_typedefs jump_to_single_result=true ignore_current_line=true<cr>",
            desc = "Goto Type Definition"
          }
          maps.n.gI = {
            "<cmd>FzfLua lsp_implementations jump_to_single_result=true ignore_current_line=true<cr>",
            desc = "Goto Implementation"
          }
          maps.n.gr = {
            "<cmd>FzfLua lsp_references jump_to_single_result=true ignore_current_line=true<cr>",
            desc = "References",
            nowait = true,
          }
          maps.n["<Leader>lX"] = {
            function() require("fzf-lua").diagnostics_document() end,
            desc = "Search diagnostics"
          }
          maps.n["<Leader>ls"] = { function()
              require("fzf-lua").lsp_document_symbols {
                regex_filter = symbols_filter,
              }
            end,
            desc = "Goto Symbol"
          }
          maps.n["<Leader>lS"] = { function()
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
      "folke/todo-comments.nvim",
      optional = true,
      -- stylua: ignore
      keys = {
        { "<Leader>ft", function() require("todo-comments.fzf").todo() end, desc = "Todo"},
        { "<Leader>fT", function() require("todo-comments.fzf").todo({keywords = {"TODO", "FIX", "FIXME"}})end, desc = "Todo/Fix/Fixme" }
      },
    },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings or {}
        maps.n["<Leader>f"] = vim.tbl_get(opts, "_map_sections", "f")

        -- common
        maps.n["<Leader>:"] = { function() require("fzf-lua").command_history() end, desc = "Find command history" }

        if vim.fn.executable "git" == 1 then
          maps.n["<Leader>g"] = vim.tbl_get(opts, "_map_sections", "g")
          maps.n["<Leader>gb"] = { "<cmd>FzfLua git_branches<cr>", desc = "Git branches" }
          maps.n["<Leader>gc"] = { "<cmd>FzfLua git_commits<cr>", desc = "Git commits (repository)" }
          maps.n["<Leader>gC"] = { "<cmd>FzfLua git_bcommits<cr>", desc = "Git commits (current file)" }
          maps.n["<Leader>gt"] = { "<cmd>FzfLua git_status<cr>", desc = "Git status" }
        end
        maps.n["<Leader>f<CR>"] = { "<cmd>FzfLua resume<cr>", desc = "Resume previous search" }
        maps.n["<Leader>f'"] = { "<cmd>FzfLua marks<cr>", desc = "Find marks" }
        maps.n["<Leader>f/"] = { "<cmd>FzfLua grep_curbuf<cr>", desc = "Find words in current buffer" }
        maps.n["<Leader>fx"] = { "<cmd>FzfLua diagnostics_document<cr>", desc = "Find Document Diagnostics" }
        maps.n["<Leader>fX"] = { "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Find Workspace Diagnostics" }
        maps.n["<Leader>fa"] = { "<cmd>FzfLua autocmds<cr>", desc = "Find autocmds" }
        maps.n["<Leader>fb"] = { "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "Find buffers" }
        maps.n["<Leader>fc"] = { function() open "grep_cword" end, desc = "Find word under cursor" }
        maps.n["<Leader>fC"] = { "<cmd>FzfLua commands<cr>", desc = "Find commands" }
        maps.n["<Leader>ff"] = { "<cmd>FzfLua files<cr>", desc = "Find files" }
        maps.n["<Leader>fh"] = { "<cmd>FzfLua help_tags<cr>", desc = "Find help" }
        maps.n["<Leader>fk"] = { "<cmd>FzfLua keymaps<cr>", desc = "Find keymaps" }
        maps.n["<Leader>fm"] = { "<cmd>FzfLua man_pages<cr>", desc = "Find man pages" }
        maps.n["<Leader>fl"] = { "<cmd>FzfLua loclist<cr>", desc = "Find location list" }
        maps.n["<Leader>fq"] = { "<cmd>FzfLua quickfix<cr>",  desc = "Find Quickfix"}
        if require("astrocore").is_available("snacks.nvim") then
          maps.n["<Leader>fn"] = {
            function() require("snacks").notifier.show_history() end,
            desc = "Find notifications",
          }
        end
        maps.n["<Leader>fo"] = { "<cmd>FzfLua oldfiles<cr>", desc = "Recent Files" }
        maps.n["<Leader>fr"] = { "<cmd>FzfLua registers<cr>", desc = "Find registers" }
        maps.n["<Leader>fs"] = { "<cmd>FzfLua colorschemes<cr>", desc = "Find themes" }
        maps.n["<Leader>fg"] = { "<cmd>FzfLua git_files<cr>", desc = "Find Files(git-files)" }
        if vim.fn.executable "rg" == 1 or vim.fn.executable "grep" == 1 then
          maps.n["<Leader>fw"] = { function() open "live_grep" end, desc = "Find words" }
          maps.v["<Leader>fw"] = { function() open "grep_visual" end, desc = "Selection(Root Dir)" }
        end
      end,
    },
  },
  dependencies = {
    "echasnovski/mini.icons"
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
    if require("astrocore").is_available("trouble.nvim") then
      config.defaults.actions.files["ctrl-t"] = require("trouble.sources.fzf").actions.open
    end

    -- diffview
    if require("astrocore").is_available("diffview.nvim") then
      config.defaults.git.commits.actions["ctrl-r"] = function(selected, opts)
        local commit_hash = selected[1]:match("[^ ]+")
        vim.cmd.DiffviewOpen{ commit_hash }
      end
      config.defaults.git.bcommits.actions["ctrl-r"] = function(selected, opts)
        local commit_hash = selected[1]:match("[^ ]+")
        vim.cmd.DiffviewOpen{ commit_hash }
      end
      config.defaults.git.branches.actions["ctrl-r"] = function(selected, opts)
        local branch = selected[1]:match("[^%s%*]+")
        vim.cmd.DiffviewOpen { branch }
      end
    end

    local img_previewer ---@type string[]?
    for _, v in ipairs {
      { cmd = "ueberzug", args = {} },
      { cmd = "chafa", args = { "{file}", "--format=symbols" } },
      { cmd = "viu", args = { "-b" } },
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
        local opts = require("astrocore").plugin_opts "fzf-lua" or {}
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
