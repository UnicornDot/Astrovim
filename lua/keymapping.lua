local M = {}
local utils = require "utils"
local astrobuffer = require "astrocore.buffer"

function M.core_mappings(mappings)
  if not mappings then mappings = require("astrocore").empty_map_table() end
  local maps = mappings
  if maps then

    maps.n["<Leader>n"] = false
    maps.n["<Leader>g"] = { desc = " Git" }
    maps.n["<Leader>w"] = { desc = "󰀽 window" }
    maps.n["<Leader>t"] = { desc = " Terminal" }
    maps.n["<Leader>T"] = { desc = " Test" }
    maps.n["<Leader>f"] = { desc = " Find" }
    maps.n["<Leader>b"] = { desc = " Buffer" }
    maps.n["<Leader>s"] = { desc = " Replace" }
    maps.n["<Leader>d"] = { desc = " Debuger" }
    maps.n["<Leader>u"] = { desc = "󰙀 UI" }
    maps.n["<Leader>p"] = { desc = " Package" }
    maps.n["<Leader>l"] = { desc = " Lsp" }
    maps.n["<Leader>x"] = { desc = " QickFix" }
    maps.n["<Leader>r"] = { desc = " Run" }
    maps.n["<Leader>m"] = { desc = "󱋼 Marks" }
    maps.x["<Leader>l"] = { desc = " Lsp" }
    maps.v["<Leader>l"] = { desc = " Lsp" }

    maps.v["<"] = { "<gv", desc = "Unindent line" }
    maps.v[">"] = { ">gv", desc = "Indent line" }
    maps.v["K"] = { ":move '<-2<CR>gv-gv", desc = "Move line up", silent = true }
    maps.v["J"] = { ":move '>+1<CR>gv-gv", desc = "Move line down", silent = true }

    maps.i["jj"] = { "<ESC>", desc = "escape", silent = true }
    maps.i["jk"] = { "<ESC>", desc = "escape", silent = true }
    maps.i["<C-o>"] = { "<ESC>o", desc = "quick nextline", silent = true }
    maps.i["<C-a>"] = { "<ESC>A", desc = "quick tailline", silent = true }

    maps.n["K"] = { "5k", desc = "move fast", silent = true }
    maps.n["J"] = { "5j", desc = "move fast", silent = true }
    maps.n["H"] = { "^", desc = "Go to start without blank" }
    maps.n["L"] = { "$", desc = "Go to end without blank" }
    maps.n["s"] = "<Nop>"
    -- 在visual mode 里粘贴不要复制
    maps.n["x"] = { '"_x', desc = "Cut without copy" }

    maps.n["<TAB>"] = { function() astrobuffer.nav(vim.v.count > 0 and vim.v.count or 1) end, desc = "Next buffer" }
    maps.n["<S-TAB>"] = { function() astrobuffer.nav(-(vim.v.count > 0 and vim.v.count or 1)) end, desc = "Previous buffer" }


    -- close search highlight
    maps.n["<Leader>th"] = { ":nohlsearch<CR>", desc = "Close search highlight" }
    maps.n["<Leader><Leader>"] = { desc = "User" }

    maps.n.n = { utils.better_search "n", desc = "Next search" }
    maps.n.N = { utils.better_search "N", desc = "Previous search" }

    if vim.fn.executable "btm" == 1 then
      maps.n["<Leader>tt"] = {
        utils.toggle_btm(),
        desc = "ToggleTerm btm"
      }
    end

    if vim.fn.executable "lazygit" == 1 then
      maps.n["<Leader>gg"] = {
        require("snacks.lazygit").open,
        desc = "ToggleTerm lazygit",
      }
    end

    if vim.fn.executable "lazydocker" == 1 then
      maps.n["<Leader>td"] = {
        utils.toggle_lazy_docker(),
        desc = "ToggleTerm lazydocker",
      }
    end

    -- multi style open terminal
    maps.n["<M-3>"] = { "<cmd>ToggleTerm direction=float<cr>", desc = "ToggleTerm float" }
    maps.t["<M-3>"] = { "<cmd>ToggleTerm direction=float<cr>", desc = "ToggleTerm float" }
    maps.n["<M-1>"] = { "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "ToggleTerm horizontal split" }
    maps.t["<M-1>"] = { "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "ToggleTerm horizontal split" }
    maps.n["<M-2>"] = { "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "ToggleTerm vertical split" }
    maps.t["<M-2>"] = { "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "ToggleTerm vertical split" }
    maps.n["<C-\\>"] = { "<cmd>ToggleTerm size=90 direction=float<cr>", desc = "Toggle float terminal" }
    maps.t["<C-\\>"] = maps.n["<C-\\>"]

    -- 分屏快捷键
    maps.n["<Leader>wc"] = { "<C-w>c", desc = "Close current screen" }
    maps.n["<Leader>wo"] = { "<C-w>o", desc = "Close other screen" }
    maps.n["<Leader>we"] = { "<C-w>=", desc = "Equals all Window"}
    maps.n["<M-l>"] = {
      function() require("astrocore.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
      desc = "Next buffer"
    }
    maps.n["<M-h>"] = {
      function() require("astrocore.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
      desc = "Previous buffer",
    }
    maps.n["<Leader>bo"] = { function() require("astrocore.buffer").close_all(true) end, desc = "Close all buffers except current" }
    maps.n["<Leader>ba"] = { function() require("astrocore.buffer").close_all() end, desc = "Close all buffers" }
    maps.n["<Leader>bc"] = { function() require("astrocore.buffer").close() end, desc = "Close buffer" }
    maps.n["<Leader>bC"] = { function() require("astrocore.buffer").close(0, true) end, desc = "Force close buffer" }
    maps.n["<Leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" }
  end
  return maps
end

function M.lsp_mappings(mappings)
  if not mappings then mappings = require("astrocore").empty_map_table() end
  local maps = mappings
  if maps then
      maps.n["M"] = { function() vim.lsp.buf.hover() end, desc = "Hover symbol details", cond = "textDocument/hover" }
      maps.n["K"] = { "5k", desc = "fast move", silent = true }
      maps.n["<Leader>lA"] = {
        function()
          vim.lsp.buf.code_action( {
            content = { only = { "source", "refactor", "quickfix" }}
          })
        end,
        desc = "code action with more",
      }
      maps.n['gK'] = false
      maps.i["<C-h>"] = {
        function() vim.lsp.buf.signature_help() end,
        desc = "Signature help",
        cond = "textDocument/signatureHelp",
      }
  end
end

return M
