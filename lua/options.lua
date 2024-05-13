-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/AstroNvim/AstroNvim/blob/main/lua/astronvim/options.lua
-- Add any additional options here

if string.match(vim.loop.os_uname().sysname,"Windows") == "Windows" then
  vim.opt.shell = "pwsh.exe -NoLogo"
  vim.opt.shellcmdflag =
	  "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  vim.cmd([[
		  let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
		  let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
		  set shellquote= shellxquote=
    ]])
end

vim.opt.conceallevel = 2 -- enable conceal
vim.opt.concealcursor = ""
vim.opt.list = false -- show whitespace characters
vim.opt.listchars = { tab = "│→", extends = "⟩", precedes = "⟨", trail = "·", nbsp = "␣" }
vim.opt.showbreak = "↪ "
vim.opt.showtabline = (vim.t.bufs and #vim.t.bufs > 1) and 2 or 1
vim.opt.spellfile = vim.fn.expand "~/.config/nvim/spell/en.utf-8.add"
vim.opt.splitkeep = "screen"
vim.opt.swapfile = false
vim.opt.thesaurus = vim.fn.expand "~/.config/nvim/spell/mthesaur.txt"
vim.opt.wrap = false -- soft wrap lines
vim.opt.scrolloff = 8 -- keep 3 lines when scrolling

vim.g.resession_enabled = false
vim.g.transparent_background = true
vim.g.autoformat = true
