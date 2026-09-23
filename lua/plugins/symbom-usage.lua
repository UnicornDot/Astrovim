-- REF: https://github.com/Wansmer/symbol-usage.nvim?tab=readme-ov-file#bubbles
local function text_format(symbol)
  local res = {}

  local round_start = { "", "SymbolUsageRounding" }
  local round_end = { "", "SymbolUsageRounding" }

  -- Indicator that shows if there are any other symbols in the same line
  local stacked_functions_content = symbol.stacked_count > 0 and ("+%s"):format(symbol.stacked_count) or ""

  if symbol.references then
    local usage = symbol.references <= 1 and "usage" or "usages"
    local num = symbol.references == 0 and "no" or symbol.references
    table.insert(res, round_start)
    table.insert(res, { "󰌹 ", "SymbolUsageRef" })
    table.insert(res, { ("%s %s"):format(num, usage), "SymbolUsageContent" })
    table.insert(res, round_end)
  end

  if symbol.definition then
    if #res > 0 then table.insert(res, { " ", "NonText" }) end
    table.insert(res, round_start)
    table.insert(res, { "󰳽 ", "SymbolUsageDef" })
    table.insert(res, { symbol.definition .. " defs", "SymbolUsageContent" })
    table.insert(res, round_end)
  end

  if symbol.implementation then
    if #res > 0 then table.insert(res, { " ", "NonText" }) end
    table.insert(res, round_start)
    table.insert(res, { "󰡱 ", "SymbolUsageImpl" })
    table.insert(res, { symbol.implementation .. " impls", "SymbolUsageContent" })
    table.insert(res, round_end)
  end

  if stacked_functions_content ~= "" then
    if #res > 0 then table.insert(res, { " ", "NonText" }) end
    table.insert(res, round_start)
    table.insert(res, { " ", "SymbolUsageImpl" })
    table.insert(res, { stacked_functions_content, "SymbolUsageContent" })
    table.insert(res, round_end)
  end

  return res
end

---@type LazyPluginSpec
return {
  -- DESC: Show references, definitions and implementations of symbols.
  ---@module "symbol-usage"
  "Wansmer/symbol-usage.nvim",
  event = "LspAttach",

  ---@type UserOpts
  opts = {
    references = { enabled = true, include_declaration = false },
    definition = { enabled = true },
    implementation = { enabled = true },
    text_format = text_format,

    disable = {
      filetypes = {
        -- IMPORTANT: Keep `""` as the first element.
        "",
        "netrw",
        "tutor",
        "man",
        "qf",
        "log",
        "alpha",
        "aerial",
        "aerial-nav",
        "bigfile",
        "cmp_menu",
        "blink-cmp-menu",
        "blink-cmp-documentation",
        "blink-cmp-signature",
        "blink-cmp-dot-repeat",
        "chatgpt-input",
        "codecompanion",
        "crunner",
        "diff",
        "DiffviewFiles",
        "DiffviewFileHistory",
        "flash_prompt",
        "glowpreview",
        "grug-far",
        "grug-far-history",
        "grug-far-help",
        "hydra_hint",
        "image",
        "lazy",
        "lazy_backdrop",
        "lspinfo",
        "mason",
        "notify",
        "noice",
        "NvimTree",
        "NvimTreeFilter",
        "snacks_input",
        "snacks_picker_input",
        "snacks_picker_list",
        "snacks_picker_preview",
        "snacks_notif",
        "snacks_notif_history",
        "snacks_layout_box",
        "snacks_win",
        "snacks_win_help",
        "snacks_win_backdrop",
        "snacks_dashboard",
        "snacks_terminal",
        "sidekick_terminal",
        "TelescopePrompt",
        "TelescopeResults",
        "terminal",
        "toggleterm",
        "trouble",
        "yazi",
      },
      cond = {
        function(bufnr)
          if vim.bo[bufnr].buftype ~= "" then return true end
          -- NOTE: Diagnosing python library files is resource intensive.
          -- if vim.bo[bufnr].filetype == "python" then return fvim.python.library_root(bufnr) end
        end,
      },
      lsp = { "dockerls" },
    },
  },

  config = function(_, opts)
    require("symbol-usage").setup(opts)

    -- ════════════════════ Bubbles Style ═════════════════════

    -- NOTE: The highlight groups should be defined in `config` instead of `init` since colorscheme may change highlights.
    -- REF: https://github.com/Wansmer/symbol-usage.nvim?tab=readme-ov-file#bubbles
    local function h(name) return vim.api.nvim_get_hl(0, { name = name }) end
    -- hl-groups can have any name
    vim.api.nvim_set_hl(0, "SymbolUsageRounding", { fg = h("CursorLine").bg, italic = true, bold = true })
    vim.api.nvim_set_hl(
      0,
      "SymbolUsageContent",
      { fg = h("Comment").fg, bg = h("CursorLine").bg, italic = true, bold = true }
    )
    vim.api.nvim_set_hl(
      0,
      "SymbolUsageRef",
      { fg = h("Function").fg, bg = h("CursorLine").bg, italic = true, bold = true }
    )
    vim.api.nvim_set_hl(0, "SymbolUsageDef", { fg = h("Type").fg, bg = h("CursorLine").bg, italic = true, bold = true })
    vim.api.nvim_set_hl(
      0,
      "SymbolUsageImpl",
      { fg = h("@keyword").fg, bg = h("CursorLine").bg, italic = true, bold = true }
    )
  end,
}
