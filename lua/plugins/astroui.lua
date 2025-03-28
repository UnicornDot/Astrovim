---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    version = false,
    branch = "v3",
    ---@type AstroUIOpts
    opts = {
      -- colorscheme = "solarized-osaka",
      colorscheme = "catppuccin-mocha",
      highlights = {}
    },
  },
  -- icon
  {
    "onsails/lspkind.nvim",
    opts = function(_, opts)
      opts.preset = "codicons"
      opts.symbol_map = require "icons.lspkind"
      opts.before = function(_, vim_item)
        local max_width = math.floor(0.25 * vim.o.columns)
        local label = vim_item.abbr
        local truncated_label = vim.fn.strcharpart(label, 0, max_width)
        if truncated_label ~= label then vim_item.abbr = truncated_label .. "…" end
        return vim_item
      end
      return opts
    end,
  },
}
