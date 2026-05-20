local astrocore = require("astrocore")

return {
  {
    "p00f/clangd_extensions.nvim",
    ft = { "cpp", "c" },
    lazy = true,
    specs = {
      "AstroNvim/astrolsp",
      optional = true,
      opts = function(_, opts)
        if require("utils").is_linux_arm() then
          opts.servers = astrocore.list_insert_unique(opts.servers, { "clangd" })
        end
        opts.config = vim.tbl_deep_extend("keep", opts.config or {}, {
          clangd = {
            capabilities = {
              offsetEncoding = "utf-8",
            },
            fallbackFlags = { "-std=c++20" },
          },
        })
        opts.autocmds.clangd_extensions = {
          {
            event = "LspAttach",
            desc = "Load clangd_extensions with clangd",
            callback = function(args)
              if assert(vim.lsp.get_client_by_id(args.data.client_id)).name == "clangd" then
                require "clangd_extensions"
                vim.api.nvim_del_augroup_by_name "clangd_extensions"
              end
            end,
          },
        }
        opts.autocmds.clangd_extension_mappings = {
          {
            event = "LspAttach",
            desc = "Load clangd_extensions with clangd",
            callback = function(args)
              if assert(vim.lsp.get_client_by_id(args.data.client_id)).name == "clangd" then
                astrocore.set_mappings({
                  n = {
                    ["<Leader>lw"] = { "<Cmd>ClangdSwitchSourceHeader<CR>", desc = "Switch source/header file" },
                  },
                }, { buffer = args.buf })
              end
            end,
          },
        }
      end,
    },
  },
  {
    "Civitasv/cmake-tools.nvim",
    lazy = true,
    ft = { "c", "cpp", "objc", "objcpp", "cuda", "proto", "cmake" },
    opts = {},
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    lazy = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "codelldb" })
    end,
  },
  {
    "Mythos-404/xmake.nvim",
    version = "^3",
    lazy = true,
    event = "BufReadPost xmake.lua",
    config = true,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = true,
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "clangd" })
    end,
  }
}
