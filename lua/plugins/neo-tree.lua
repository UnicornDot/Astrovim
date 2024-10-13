local get_path_type = require("utils").get_path_type
local get_extension = require("utils").get_extension
local get_filename_without_extension = require("utils").get_filename_without_extension
local get_immediate_parent_directory = require("utils").get_immediate_parent_directory
local write_to_file = require("utils").write_to_file
local select_ui = require("utils").select_ui
local inputs = require("neo-tree.ui.inputs")
local insert_to_file_first_line = require("utils").insert_to_file_first_line
local get_parent_directory = require("utils").get_parent_directory

local file_exists = require("utils").file_exists
-- local remove_cwd = require("utils").remove_cwd
local remove_lsp_cwd = require("utils").remove_lsp_cwd
local get_lsp_root_dir = require("utils").get_lsp_root_dir


local file_extension_mapping = {
  go = function(file_path)
    local parent_name = get_immediate_parent_directory(file_path)
    if parent_name == nil then parent_name = "main" end
    write_to_file(file_path, "package " .. parent_name .. "\n")
  end,
  api = function(file_path)
    write_to_file(file_path,'syntax = "v1"')
  end,
  proto = function(file_path)
    write_to_file(
      file_path
      'syntax = "proto3";\nimport "buf/validate/validate.proto";\n'
    )
  end,
  rs = function(path)
    local parent_name = get_immediate_parent_directory(path)
    local relative_path = remove_lsp_cwd(path, "rust-analyzer")

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
                  filename = get_filename_without_extension(path)
                  write_to_file(lib_path, "mod " .. filename .. ";\n")
                end)
              else
                insert_to_file_first_line(lib_path, "mod " .. filename .. ";\n")
              end
              -- if a window for this lib_path already exists, refresh it
              vim.schedule(function() vim.cmd("e " .. lib_path) end)
            elseif select == "src/main.rs" then
              if not file_exists(main_path) then
                inputs.input(
                  "Create `src/main.rs` (Y/N): ",
                    nil,
                  function()
                    write_to_file(lib_path, "mod " .. filename .. ";\n")
                  end
                )
              else
                insert_to_file_first_line(main_path, "mod " .. filename .. ";\n")
              end
              -- if a window for this lib_path already exists, refresh it
              vim.schedule(function() vim.cmd("e " .. main_path) end)
            end
          end)
        end
      end
    elseif relative_path and string.find(relative_path, "^/src/") then
      local filename = get_filename_without_extension(path)
      local mod_path = get_parent_directory(path) .. "mod.rs"
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
  unknown = function() end,
}

---@type LazySpec
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    deactivate = function() vim.cmd [[Neotree close]] end,
    opts = function(_, opts)
      local neo_tree_events = require "neo-tree.events"
      return require("astrocore").extend_tbl(opts, {
        open_files_do_not_replace_types = {
          "terminal", "Trouble", "trouble", "qf", "Outline"
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
                  if language_mapping() then pcall(language_mapping, file_path) end
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
        },
      })
    end,
  },
}
