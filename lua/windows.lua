-- windows / work config

if vim.fn.has("win32") == 1 then
	vim.o.shell = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -NoLogo -ExecutionPolicy Unrestricted"
	vim.o.shellpipe = "> %s 2>&1"
	vim.cmd([[set shellquote= shellxquote=]])
	if WorkConfig.enabled then
		vim.opt.rtp:append(vim.fn.stdpath("config") .. "C:/Users/ccummings/AppData/Local/nvim/runtime")
		vim.env.TEMP = "C:\\Users\\ccummings\\AppData\\Local\\Temp"
		vim.env.RBTOOLS_CONFIG_PATH = "C:\\Users\\ccummings"
		vim.api.nvim_set_current_dir("C:\\projects\\")
	end
end
