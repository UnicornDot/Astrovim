-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/AstroNvim/AstroNvim/blob/main/lua/astronvim/options.lua
-- Add any additional options here

if string.match(vim.loop.os_uname().sysname,"Windows") == "Windows" then
  vim.opt.shell = "powershell.exe -NoLogo"
  vim.opt.shellcmdflag =
	  "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  vim.cmd([[
		  let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
		  let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
		  set shellquote= shellxquote=
    ]])
end


