-- windows / work config

local work_config = require("work_config")

if vim.fn.has("win32") == 1 then
	vim.o.shell = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -NoLogo -NoProfile"
	vim.o.shellcmdflag =
		"-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
	vim.o.shellpipe = "> %s 2>&1"
	vim.cmd([[set ffs=dos,unix]])
	vim.cmd([[set shellquote= shellxquote=]])
	if work_config.enabled then
		vim.opt.rtp:append(vim.fn.stdpath("config") .. "C:/Users/ccummings/AppData/Local/nvim/runtime")
		vim.env.TEMP = "C:\\Users\\ccummings\\AppData\\Local\\Temp"
		vim.env.RBTOOLS_CONFIG_PATH = "C:\\Users\\ccummings"
		vim.api.nvim_set_current_dir("C:\\projects\\")
		--DIY powershell profile, to get around work's remote execution policy
		vim.api.nvim_create_autocmd("TermOpen", {
			callback = function()
				local script = vim.fs.dirname(vim.env.MYVIMRC) .. "/powershell/powershell_profile.ps1"
				local file, err = io.open(script, "rb")
				if file then
					local ps_profile = file:read("*a")
					vim.api.nvim_chan_send(vim.bo.channel, ps_profile)
					vim.api.nvim_chan_send(vim.bo.channel, "clear\r")
					vim.api.nvim_feedkeys("Gi", "n", false)
					file:close()
				end
			end,
		})
	end
end
