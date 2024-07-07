return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.registries = require("astrocore").list_insert_unique(opts.registries, {
        "github:mason-org/mason-registry",
      })
      opts.ui = {
        check_outdated_packages_on_open = true,
        width = 0.8,
        height = 0.9,
        border = "rounded",
      }
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" },
    dependencies = { "williamboman/mason.nvim" },
    init = function(plugin) require("astrocore").on_load("mason.nvim", plugin.name) end,
    config = function(_, opts)
      local mason_tool_installer = require "mason-tool-installer"
      mason_tool_installer.setup(opts)
      mason_tool_installer.run_on_start()
    end,
  },
  { "williamboman/mason-lspconfig.nvim", opts = {} },
  { "jay-babu/mason-null-ls.nvim", optional = true, opts = {} },
  { "nvimtools/none-ls.nvim", optional = true, opts = {} },
}
