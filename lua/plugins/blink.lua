local function has_words_before()
  local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

---@type function?, function?
local icon_provider, hl_provider

local function get_kind_icon(CTX)
  -- Evaluate icon provider
  if not icon_provider then
    local _, mini_icons = pcall(require, "mini.icons")
    if _G.MiniIcons then
      icon_provider = function(ctx)
        local source_name = ctx.item.source_name
        local color = ctx.item.documentation
        -- local label = ctx.item.label
        local is_specific_color = ctx.kind_hl and ctx.kind_hl:match "^HexColor" ~= nil
        if source_name == "LSP" then
          if color and type(color) == "string" and color:match "^#%x%x%x%x%x%x$" then
            local hl = "hex-" .. color:sub(2)
            if #vim.api.nvim_get_hl(0, { name = hl }) == 0 then vim.api.nvim_set_hl(0, hl, { fg = color }) end
            ctx.kind_icon, ctx.kind_hl = "󱓻",  hl 
          else
            local icon, hl = mini_icons.get("lsp", ctx.kind or "")
            if icon then
              ctx.kind_icon = icon
              if not is_specific_color then ctx.kind_hl = hl end
            end
          end
        elseif source_name == "codeium" then
          ctx.kind_icon, ctx.kind_hl = mini_icons.get("lsp", "event")
        elseif source_name == "Path" then
          ctx.kind_icon, ctx.kind_hl = mini_icons.get(ctx.kind == "Folder" and "directory" or "file", ctx.label)
          -- ctx.kind_icon, ctx.kind_hl = label:match "%.[^/]+$" and mini_icons.get("file", label) or mini_icons.get("directory", label))
        end
      end
    end
    if not icon_provider then icon_provider = function() end end
  end
  -- Evaluate highlight provider
  if not hl_provider then
    local highlight_colors_avail, highlight_colors = pcall(require, "nvim-highlight-colors")
    if highlight_colors_avail then
      local kinds
      hl_provider = function(ctx)
        if not kinds then kinds = require("blink.cmp.types").CompletionItemKind end
        if ctx.item.kind == kinds.Color then
          local doc = vim.tbl_get(ctx, "item", "documentation")
          if doc then
            local color_item = highlight_colors_avail and highlight_colors.format(doc, { kind = kinds[kinds.Color] })
            if color_item and color_item.abbr_hl_group then
              if color_item.abbr then ctx.kind_icon = color_item.abbr end
              ctx.kind_hl = color_item.abbr_hl_group
            end
          end
        end
      end
    end
    if not hl_provider then hl_provider = function() end end
  end
  -- Call resolved providers
  icon_provider(CTX)
  hl_provider(CTX)
  -- Return text and highlight information
  return { text = CTX.kind_icon .. CTX.icon_gap, highlight = CTX.kind_hl }
end

local astrocore = require("astrocore")

return {
  {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    version = "*",
    opts_extend = {
      "sources.default",
      "cmdline.sources",
      "term.sources",
      "sources.providers.lsp.fallbacks",
    },
    opts = {
      snippets = {
        expand = function(snippet, _) return require("utils").expand(snippet) end,
      },
      cmdline = {
        enabled = true,
        keymap = nil,
        sources = function()
          local type = vim.fn.getcmdtype()
          if type == '/' or type == '?' then return { 'buffer' } end
          if type == ':' or type == '@' then return { 'cmdline' } end
          return {}
        end,
        completion = {
          trigger = {
            show_on_blocked_trigger_characters = {},
          },
          menu = {
            auto_show = nil,
            draw = {
              columns = { { 'label', 'label_description', gap = 1 } },
            },
          }
        }
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "emoji", "cmdline"},
        providers = {
          lsp = {
            ---@type fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[])
            transform_items = function(ctx, items)
              for _, item in ipairs(items) do
                if item.kind == require("blink.cmp.types").CompletionItemKind.Snippet then
                  item.score_offset = item.score_offset - 3
                end
              end

              ---@diagnostic disable-next-line: redundant-return-value
              return vim.tbl_filter(function(item)
                local c = ctx.get_cursor()
                local cursor_line = ctx.line
                local cursor = {
                  row = c[1],
                  col = c[2] + 1,
                  line = c[1] - 1,
                }
                local cursor_before_line = string.sub(cursor_line, 1, cursor.col - 1)

                if item.kind == require("blink.cmp.types").CompletionItemKind.Text then return false end
                if vim.bo.filetype == "vue" then
                  if cursor_before_line:match "(@[%w]*)%s*$" ~= nil then
                    return item.label:match "^@" ~= nil
                  elseif cursor_before_line:match "(:[%w]*)%s*$" ~= nil then
                    return item.label:match "^:" ~= nil and not item.label:match "^:on%-" ~= nil
                  elseif cursor_before_line:match "(#[%w]*)%s*$" ~= nil then
                    return item.kind == require("blink.cmp.types").CompletionItemKind.Method
                  end
                end

                return true
              end, items)
            end,
            score_offset = 200,
            async = true
          },
          emoji = {
            name = "Emoji",
            module = "blink-emoji",
            async = true,
            opts = { insert = true },
            score_offset = 15,
            should_show_items = function()
              return vim.tbl_contains({ "gitcommit", "markdown" }, vim.o.filetype)
            end
          }
        },
      },
      keymap = {
        ["<C-M>"] = { "show", "show_documentation", "hide_documentation" },
        ["<Up>"]    = { "select_prev", "fallback" },
        ["<Down>"]  = { "select_next", "fallback" },
        ["<C-N>"]   = { "snippet_forward", },
        ["<C-P>"]   = { "snippet_backward", },
        ["<C-J>"]   = { "select_next", "fallback" },
        ["<C-K>"]   = { "select_prev", "fallback" },
        ["<C-U>"]   = { "scroll_documentation_up", "fallback" },
        ["<C-D>"]   = { "scroll_documentation_down", "fallback" },
        ["<C-E>"]   = { "hide", "fallback" },
        ["<CR>"]    = { "accept", "fallback" },
        ["<Tab>"]   = {
          "select_next",
          "snippet_forward",
          function(cmp)
            if has_words_before() or vim.api.nvim_get_mode().mode == "c" then
              return cmp.show()
            end
          end,
          "fallback",
        },
        ["<S-Tab>"] = {
          "select_prev",
          "snippet_backward",
          function(cmp)
            if vim.api.nvim_get_mode().mode == "c" then return cmp.show() end
          end,
          "fallback",
        },
      },
      appearance = {
        -- sets the fallback highlight groups to nvim-cmp's highlight groups
        -- useful for when your theme doesn't support blink.cmp
        -- will be removed in a future release, assuming themes add support
        use_nvim_cmp_as_default = false,
        -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- adjusts spacing to ensure icons are aligned
        nerd_font_variant = "mono",
      },
      signature = {
        enabled = true,
        trigger = {
          blocked_trigger_characters = {},
          blocked_retrigger_characters = {},
          -- When true, will show the signature help window when the cursor comes after a trigger character when entering insert mode
          show_on_insert_on_trigger_character = true,
        },
        window = {
          border = "rounded",
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        },
      },
      completion = {
        list = { selection = { preselect = true, auto_insert = false } },
        menu = {
          scrollbar = false,
          border = "rounded",
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          draw = {
            treesitter = { "lsp" },
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "source_name" },
            },
            components = {
              kind_icon = {
                ellipsis = true,
                text = function(ctx) return get_kind_icon(ctx).text end,
                highlight = function(ctx) return get_kind_icon(ctx).highlight end,
              },
              kind = {
                ellipsis = true,
              }
            },
          },
        },
        -- NOTE: some LSPs may add auto brackets theselves anyway
        accept = {
          -- experimental auto-brackets support
          auto_brackets = {
            enabled = true,
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 300,
          window = {
            border = "rounded",
            scrollbar = false,
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          },
        },
        ghost_text = {
          enabled = true,
        },
      },
    },
    ---@param opts blink.cmp.Config | { sources: { compat : string[] } }
    config = function(_, opts)
      local enabled = opts.sources.default
      for _, provider in ipairs(opts.sources.providers or {}) do
        ---@cast provider blink.cmp.SourceProviderConfig | {kind?:string}
        if provider.kind then
          local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
          local kind_idx = #CompletionItemKind + 1

          CompletionItemKind[kind_idx] = provider.kind
          CompletionItemKind[provider.kind] = kind_idx

          local transform_items = provider.transform_items
          provider.transform_items = function(ctx, items)
            items = transform_items and transform_items(ctx, items) or items
            for _, item in ipairs(items) do
              item.kind = kind_idx or item.kind
            end
            return items
          end
          provider.kind = nil
        end
      end

      require("blink.cmp").setup(opts)
    end,

    specs = {
      { "rafamadriz/friendly-snippets", lazy = true },
      { "nvim-mini/mini.icons",         lazy = true },
      { "moyiz/blink-emoji.nvim",       lazy = true },
      {
        "L3MON4D3/LuaSnip",
        optional = true,
        specs = { { "saghen/blink.cmp", opts = { snippets = { preset = "luasnip" } } } },
      },
      {
        "AstroNvim/astrolsp",
        optional = true,
        opts = function(_, opts)
          if not opts.config then opts.config = {} end
          if not opts.config["*"] then opts.config["*"] = {} end
          opts.config["*"].capabilities = require("blink.cmp").get_lsp_capabilities(opts.config["*"].capabilities)

          -- disable AstroLSP signature help if `blink.cmp` is providing it
          local blink_opts = astrocore.plugin_opts "blink.cmp"
          if vim.tbl_get(blink_opts, "signature", "enabled") == true then
            if not opts.features then opts.features = {} end
            opts.features.signature_help = false
          end
        end,
      },
      {
        "folke/lazydev.nvim",
        optional = true,
        specs = {
          {
            "saghen/blink.cmp",
            opts = function(_, opts)
              if pcall(require, "lazydev.integrations.blink") then
                return astrocore.extend_tbl(opts, {
                  sources = {
                    -- add lazydev to your completion providers
                    default = { "lazydev" },
                    providers = {
                      lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        score_offset = 100
                      },
                    },
                  },
                })
              end
            end,
          },
        },
      },
    },
  }
}
