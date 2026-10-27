-- windows / work config

if vim.fn.has("win32") == 1 then
	vim.o.shell = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -NoLogo -ExecutionPolicy Unrestricted"
	vim.o.shellpipe = "> %s 2>&1"
	vim.cmd([[set shellquote= shellxquote=]])
	if WorkConfig.enabled then
		vim.opt.rtp:prepend("C:\\Users\\ccummings\\AppData\\local\\nvim\\share\\nvim\\runtime")
		vim.env.TEMP = "C:\\Users\\ccummings\\AppData\\Local\\Temp"
		vim.env.RBTOOLS_CONFIG_PATH = "C:\\Users\\ccummings"
		vim.env.PS_PROFILE =
			"C:\\Users\\ccummings\\OneDrive - AGS LLC\\Documents\\WindowsPowerShell\\Microsoft.PowerShell_profile.ps1"
		vim.env.GLAZEWM = "C:\\Users\\ccummings\\.glzr\\glazewm\\config.yaml"
		vim.env.YAZI = "C:\\Users\\ccummings\\AppData\\Roaming\\yazi\\config\\yazi.toml"
		vim.env.ALACRITTY = "C:\\Users\\ccummings\\AppData\\Roaming\\alacritty\\alacritty.toml"
		vim.api.nvim_set_current_dir("C:\\projects\\")
	end
end
