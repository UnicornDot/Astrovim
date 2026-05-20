local utils = require "utils"
local get_path_type = utils.get_path_type
local get_extension = utils.get_extension

local get_filename_without_extension = utils.get_filename_without_extension
local get_immediate_parent_directory = utils.get_immediate_parent_directory
local write_to_file = utils.write_to_file
local select_ui = utils.select_ui
local insert_to_file_first_line = utils.insert_to_file_first_line
local get_parent_directory = utils.get_parent_directory

local file_exists = utils.file_exists
local remove_lsp_cwd = utils.remove_lsp_cwd
local get_lsp_root_dir = utils.get_lsp_root_dir

local file_extension_mapping = {
  go = function(file_path)
    local parent_name = get_immediate_parent_directory(file_path)
    if parent_name == nil then parent_name = "main" end
    write_to_file(file_path, "package " .. parent_name .. "\n")
  end,
  api = function(file_path) write_to_file(file_path, 'syntax = "v1"') end,
  proto = function(file_path) write_to_file(file_path 'syntax = "proto3";\nimport "buf/validate/validate.proto";\n') end,
  rs = function(path)
    local parent_name = get_immediate_parent_directory(path)
    local relative_path = remove_lsp_cwd(path, "rust-analyzer")
    local inputs = require "neo-tree.ui.inputs"

    if relative_path and string.find(relative_path, "^/src/") and parent_name == "src" then
      local root_dir = get_lsp_root_dir "rust-analyzer"
      if root_dir ~= nil then
        local lib_path = root_dir .. "/src/lib.rs"
        local main_path = root_dir .. "/src/main.rs"
        local filename = get_filename_without_extension(path)
        if filename ~= "lib" and filename ~= "main" then
          local selections = {
            ["lib"] = "src/lib.rs",
            ["main"] = "src/main.rs",
          }
          select_ui(selections, "Attach File to Module:", function(select)
            if not select then return end
            if select == "src/lib.rs" then
              if not file_exists(lib_path) then
                inputs.input("Create `src/lib.rs` (Y/N): ", "Y", function()
                  write_to_file(lib_path, "mod " .. filename .. ";\n")
                  vim.cmd("e " .. lib_path)
                end)
              else
                insert_to_file_first_line(lib_path, "mod " .. filename .. ";\n")
                vim.cmd("e " .. lib_path)
              end
            elseif select == "src/main.rs" then
              if not file_exists(main_path) then
                inputs.input("Create `src/main.rs` (Y/N): ", "Y", function()
                  write_to_file(lib_path, "mod " .. filename .. ";\n")
                  vim.cmd("e " .. main_path)
                end)
              else
                insert_to_file_first_line(main_path, "mod " .. filename .. ";\n")
                vim.cmd("e " .. main_path)
              end
            end
          end)
        end
      end
    elseif relative_path and string.find(relative_path, "^/src/") then
      local filename = get_filename_without_extension(path)
      local mod_path = get_parent_directory(path) .. "/mod.rs"
      if filename == "mod" then
        return
      else
        inputs.input("Attach file to `mod.rs` (Y/N): ", nil, function(value)
          if string.lower(value) == "y" then
            if not file_exists(mod_path) then
              inputs.input("Create `mod.rs` (Y/N): ", nil, function()
                write_to_file(mod_path, "mod " .. filename .. ";\n")
                -- if a window for this lib_path already exists refresh it
                vim.schedule(function() vim.cmd("e " .. mod_path) end)
              end)
            else
              insert_to_file_first_line(mod_path, "mod " .. filename .. ";\n")
              -- if a window for this lib_path already exists, refresh it
              vim.schedule(function() vim.cmd("e " .. mod_path) end)
            end
          end
        end)
      end
    end
  end,
}

--Trash the target
local function trash(state)
  local inputs = require "neo-tree.ui.inputs"
  local node = state.tree:get_node()
  if node.type == "message" then return end
  local _, name = require("neo-tree.utils").split_path(node.path)
  local msg = string.format("Are you sure you want to trash `%s`?", name)
  inputs.confirm(msg, function(confirmed)
    if not confirmed then return end
    vim.api.nvim_command("silent !trash -F " .. "'" .. node.path .. "'")
    require("neo-tree.sources.manager").refresh(state)
  end)
end

--Trash the selections (visual mode)
local function trash_visual(state, selected_nodes)
  local inputs = require "neo-tree.ui.inputs"
  local paths_to_trash = {}
  for _, node in ipairs(selected_nodes) do
    if node.type ~= "message" then table.insert(paths_to_trash, node.path) end
  end
  local msg = "Are you sure you want to trash " .. #paths_to_trash .. "items?"
  inputs.confirm(msg, function(confirmed)
    if not confirmed then return end
    for _, path in ipairs(paths_to_trash) do
      vim.api.nvim_command("silent !trash -F " .. "'" .. path .. "'")
    end
    require("neo-tree.sources.manager").refresh(state)
  end)
end

---@type LazySpec
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = true,
    specs = {
      {
        "antosha417/nvim-lsp-file-operations",
        -- lazy will handle loading nvim-tree and neo-tree appropriately based on the module load and our `init` function
        lazy = true,
        init = function(plugin) -- lazily load plugin after a tree plugin is loaded
          -- the plugins that should trigger this one to load when they have loaded
          local triggers = { "nvim-tree.lua", "neo-tree.nvim" }

          local load_plugin = function() require("lazy").load { plugins = { plugin.name } } end
          local lazy_plugins = require("lazy.core.config").plugins

          -- check if any of the plugins are already loaded, in which case load
          for _, trigger in ipairs(triggers) do
            if vim.tbl_get(lazy_plugins, trigger, "_", "loaded") then
              vim.schedule(load_plugin)
              return
            end
          end

          -- if none, then set up autocommand to load the plugin
          local autocmd
          autocmd = vim.api.nvim_create_autocmd("User", {
            pattern = "LazyLoad",
            desc = "lazily load nvim-lsp-file-operations",
            callback = function(args)
              if vim.tbl_contains(triggers, args.data) then
                load_plugin()
                if autocmd then vim.api.nvim_del_autocmd(autocmd) end
              end
            end,
          })

          -- TODO: This entire `init` function can be simplified to the following line after AstroNvim v4 is released
          -- require("astrocore").on_load({ "neo-tree.nvim", "nvim-tree.lua" }, plugin.name)
        end,
        main = "lsp-file-operations", -- set the main module name where the `setup` function is
        opts = {},
      },
    },
    opts = function(_, opts)
      local neo_tree_events = require "neo-tree.events"
      return require("astrocore").extend_tbl(opts, {
        window = {
          mappings = {
            -- ['d'] = "trash",
          },
        },
        commands = {
          trash = trash,
          trash_visual = trash_visual,
        },
        open_files_do_not_replace_types = {
          "terminal",
          "Trouble",
          "trouble",
          "qf",
          "Outline",
        },
        event_handlers = {
          {
            event = neo_tree_events.FILE_ADDED,
            handler = function(file_path)
              local file_type = get_path_type(file_path)
              if file_type and file_type == "file" then
                local file_extension = get_extension(file_path)
                if file_extension ~= "" then
                  local language_mapping = file_extension_mapping[file_extension]
                  if language_mapping then pcall(language_mapping, file_path) end
                end
              end
            end,
          },
        },
        close_if_last_window = true,
        enable_diagnostics = true,
        popup_border_style = "rounded",
        sources = {
          "filesystem",
        },
        source_selector = {
          winbar = true,
        },
        filesystem = {
          filtered_items = {
            always_show = { ".github", ".gitignore" },
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_by_name = {
              ".git",
              "node_modules",
            },
            never_show = {
              ".DS_Store",
              "thumbs.db",
            },
          },
          group_empty_dirs = true,
          use_libuv_file_watcher = true,
        },
      })
    end,
  },
}
