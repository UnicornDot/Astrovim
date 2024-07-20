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
}
