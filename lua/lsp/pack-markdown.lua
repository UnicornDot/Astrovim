local astrocore = require "astrocore"
local utils = require "utils"

local markdown_table_change = function()
  Snacks.input({ prompt = "Separate Char: " }, function(input)
    if not input or #input == 0 then return end
    local execute_command = ([[:'<,'>MakeTable! ]] .. input)
    vim.cmd(execute_command)
  end)
end

local function diagnostic()
  local system_config = vim.fn.stdpath "config" .. "/.markdownlint.jsonc"
  local project_config = vim.fn.getcwd() .. "/.markdownlint.jsonc"

  local markdownlint = require("lint").linters.markdownlint
  if not utils.contains_arg(markdownlint.args, "--config") then
    table.insert(markdownlint.args, "--config")
  end
  if vim.fn.filereadable(project_config) == 1 then
    if not utils.contains_arg(markdownlint.args, project_config) then
      table.insert(markdownlint.args, project_config)
    end
  else
    if not utils.contains_arg(markdownlint.args, system_config) then
      table.insert(markdownlint.args, system_config)
    end
  end
  return markdownlint.args
end

---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      return astrocore.extend_tbl(opts, {
        options = {
          g = {
            mkdp_auto_close = 0,
            mkdp_combine_preview = 1,
          },
        },
      })
    end,
  },
  {
    "AstroNvim/astrolsp",
    ---@type function
    opts = function(_, opts)
      opts.config = vim.tbl_deep_extend("keep", opts.config or {}, {
        marksman = {
          on_attach = function()
            if astrocore.is_available "markdown-preview.nvim" then
              astrocore.set_mappings({
                n = {
                  ["<Leader>lz"] = { "<cmd>MarkdownPreview<CR>", desc = "Markdown Start Preview" },
                  ["<Leader>lZ"] = { "<cmd>MarkdownPreviewStop<CR>", desc = "Markdown Stop Preview" },
                  ["<Leader>lp"] = { "<cmd>Pastify<CR>", desc = "Markdown Paste Image" },
                },
                x = {
                  ["<Leader>lt"] = { [[:'<,'>MakeTable! \t<CR>]], desc = "Markdown csv to table(Default:\\t)" },
                  ["<Leader>lT"] = { markdown_table_change, desc = "Markdown csv to table with separate char" },
                },
              }, { buffer = true })
            end
          end,
        },
      })
    end
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = true,
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(
        opts.ensure_installed, { "marksman", "prettierd", "markdownlint" }
      )
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    lazy = true,
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown", "markdown.mdx" },
    build = function() vim.fn["mkdp#util#install"]() end,
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_open_to_the_world = 1
      vim.g.mkdp_port = "8873"
      vim.g.mkdp_theme = "light"
      vim.g.mkdp_combine_preview = 1
    end,
  },
  {
    "HakonHarnes/img-clip.nvim",
    lazy = true,
    cmd = { "PasteImage", "ImgClipDebug", "ImgClipConfig" },
    opts = {
      default = {
        prompt_for_file_name = false,
        embed_image_as_base64 = false,
        drag_and_drop = {
          enabled = true,
          insert_mode = true,
        },
        use_absolute_path = vim.fn.has "win32" == 1,
        relative_to_current_file = true,
        show_dir_path_in_prompt = true,
        dir_path = "assets/imgs/",
      },
    },
  },
  {
    "TobinPalmer/pastify.nvim",
    lazy = true,
    cmd = { "Pastify" },
    opts = {
      absolute_path = false,
      apikey = "",
      local_path = "/assets/imgs/",
      save = "local",
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    lazy = true,
    ft = { "markdown", "markdown.mdx" },
    event = "User AstroFile",
    opts = {
      bullet = {
        right_pad = 1,
      },
      heading = { position = "inline" }
    },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
  },
  {
    "OXY2DEV/helpview.nvim",
    lazy = true,
    event = "VeryLazy",
    ft = "help",
  },
  {
    "mattn/vim-maketable",
    lazy = true,
    cmd = "MakeTable",
    ft = { "markdown", "markdown.mdx" },
  },
  {
    "stevearc/conform.nvim",
    lazy = true,
    optional = true,
    opts = {
      formatters_by_ft = {
        markdown = { "prettierd", stop_after_first = true },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    lazy = true,
    optional = true,
    opts = {
      linters = {
        markdownlint = {
          args = diagnostic()
        }
      },
      linters_by_ft = {
        markdown = { "markdownlint" }
      }
    }
  }
}
