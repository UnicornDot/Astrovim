local astrocore = require "astrocore"

local markdown_table_change = function()
  vim.ui.input({ prompt = "Separate Char: " }, function(input)
    if not input or #input == 0 then return end
    local execute_command = ([[:'<,'>MakeTable! ]] .. input)
    vim.cmd(execute_command)
  end)
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
    ---@type AstroLSPOpts
    opts = {
      ---@diagnostic disable: missing-fields
      config = {
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
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "markdown", "markdown_inline", "html", "latex" })
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts) opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "marksman" }) end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed,{ "prettierd", "markdownlint" })
      opts.handlers.markdownlint = function()
        local null_ls = require "null-ls"
        local markdownlint_diagnostics_buildins = null_ls.builtins.diagnostics.markdownlint
        table.insert(markdownlint_diagnostics_buildins._opts.args, "--config")
        local system_config = vim.fn.stdpath "config" .. "/.markdownlint.jsonc"
        local project_config = vim.fn.getcwd() .. "/.markdownlint.jsonc"
        if vim.fn.filereadable(project_config) == 1 then
          table.insert(markdownlint_diagnostics_buildins._opts.args, project_config)
        else
          table.insert(markdownlint_diagnostics_buildins._opts.args, system_config)
        end
        null_ls.register(null_ls.builtins.diagnostics.markdownlint.with {
          generator_opts = markdownlint_diagnostics_buildins._opts,
        })
      end
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown", "markdown.mdx" },
    build = function() vim.fn["mkdp#util#install"]() end,
    init = function()
      local plugin = require("lazy.core.config").spec.plugins["markdown-preview.nvim"]
      vim.g.mkdp_filetypes = require("lazy.core.plugin").values(plugin, "ft", true)
    end
  },
  {
    "TobinPalmer/pastify.nvim",
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
    ft = { "markdown", "markdown.mdx" },
    event = "VeryLazy",
    opts = {
      bullet = {
        right_pad = 1,
      },
    },
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
  },
  {
    "mattn/vim-maketable",
    cmd = "MakeTable",
    event = "BufEnter",
    ft = "markdown",
  }
}
