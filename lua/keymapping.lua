local M = {}
local utils = require "utils"
local astrobuffer = require "astrocore.buffer"
local astrocore = require("astrocore")

function M.core_mappings(mappings)
  if not mappings then mappings = astrocore.empty_map_table() end
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
    -- maps.n["<Leader>m"] = { desc = " Man" }

    maps.n["+"] = { "<C-a>", desc = "Increment under cursor", noremap = true }
    maps.n["-"] = { "<C-x>", desc = "Decrement under cursor", noremap = true }
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
      maps.n["<Leader>tt"] = { utils.toggle_btm(), desc = "ToggleTerm btm" }
    end

    if vim.fn.executable "lazygit" == 1 then
      maps.n["<Leader>gg"] = { require("snacks.lazygit").open, desc = "ToggleTerm lazygit",
      }
    end

    if vim.fn.executable "lazydocker" == 1 then
      maps.n["<Leader>td"] = { utils.toggle_lazy_docker(), desc = "ToggleTerm lazydocker", }
    end

    -- multi style open terminal
    maps.n["<M-1>"] = { function() require("snacks.terminal").toggle(nil, {win={position="bottom", height=0.15 }}) end, desc = "Snacks terminal horizontal" }
    maps.t["<M-1>"] = maps.n["<M-1>"]
    maps.n["<M-2>"] = { function() require("snacks.terminal").toggle(nil, {win={position="right", width=0.4 }}) end, desc = "Snacks terminal vertical" }
    maps.t["<M-2>"] = maps.n["<M-2>"]
    maps.n["<M-3>"] = { function() require("snacks.terminal").toggle(nil, {win={position="float", border = "rounded" }}) end, desc = "Snacks terminal float" }
    maps.t["<M-3>"] = maps.n["<M-3>"]
    maps.n["<C-\\>"] = { function() require("snacks.terminal").toggle(nil, {win={position="float", border = "rounded" }}) end, desc = "Snacks terminal float large" }
    maps.t["<C-\\>"] = maps.n["<C-\\>"]

    -- 分屏快捷键
    maps.n["<Leader>wc"] = { "<C-w>c", desc = "Close current screen" }
    maps.n["<Leader>wo"] = { "<C-w>o", desc = "Close other screen" }
    maps.n["<Leader>we"] = { "<C-w>=", desc = "Equals all Window"}
    maps.n["<M-l>"] = {
      function() astrobuffer.nav(vim.v.count > 0 and vim.v.count or 1) end,
      desc = "Next buffer"
    }
    maps.n["<M-h>"] = {
      function() astrobuffer.nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
      desc = "Previous buffer",
    }
    maps.n["<Leader>bo"] = { function() astrobuffer.close_all(true) end, desc = "Close all buffers except current" }
    maps.n["<Leader>ba"] = { function() astrobuffer.close_all() end, desc = "Close all buffers" }
    maps.n["<Leader>bc"] = { function() astrobuffer.close() end, desc = "Close buffer" }
    maps.n["<Leader>bC"] = { function() aeastrobuffer.close(0, true) end, desc = "Force close buffer" }
    maps.n["<Leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" }
  end
  return maps
end

function M.lsp_mappings(mappings)
  if not mappings then mappings = astrocore.empty_map_table() end
  local maps = mappings
  if maps then
      maps.n["M"] = { function() vim.lsp.buf.hover() end, desc = "Hover symbol details", cond = "textDocument/hover" }
      maps.i["<C-h>"] = {
        function() vim.lsp.buf.signature_help() end,
        desc = "Signature help",
        cond = "textDocument/signatureHelp",
      }
      maps.n["grr"] = {
        function() require("snacks").picker.lsp_references() end,
        desc = "vim.lsp.buf.reference"
      }
      maps.n["grd"] = {
        function() require("snacks").picker.lsp_definitions() end,
        desc = "vim.lsp.buf.definitions"
      }
      maps.n["gri"] = {
        function() require("snacks").picker.lsp_implementations() end,
        desc = "vim.lsp.buf.implementations"
      }
      maps.n["grt"] = {
        function() require("snacks").picker.lsp_type_definitions() end,
        desc = "vim.lsp.buf.implementations"
      }
      maps.n["gra"] = {
        function() require("snacks").picker.lsp_config() end,
        desc = "vim.lsp.buf.code_action"
      }
      maps.n['grx'] = {
        function() vim.lsp.codelens.run() end,
        desc = "vim.lsp.codelens_run"
      }
      maps.n['grn'] = {
        function() require('snacks').rename() end,
        desc = "vim.lsp.rename"
      }

  end
end

return M
