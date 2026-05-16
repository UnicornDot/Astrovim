local astrocore = require("astrocore")

---@type LazySpec
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  optional = true,
  opts = function(_, opts)
    opts.ensure_installed = astrocore.list_insert_unique(opts.ensure_installed, { "thriftls" })
  end,
}
