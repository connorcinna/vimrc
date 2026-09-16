local dap = require("dap")

dap.adapters.coreclr = {
	type = "executable",
	command = vim.fn.stdpath("data") .. "\\mason\\bin\\netcoredbg.cmd",
	args = { "--interpreter=vscode" },
}

dap.configurations.cs = {
	{
		type = "coreclr",
		name = "attach - netcoredbg",
		request = "attach",
		program = require("dap.utils").pick_process,
	},
}

-- Registers the `unity` adapter (vstuc) and, with enable_unity_cs_configuration,
-- adds the auto-detecting "Attach to Unity" config for a local Editor.
require("nvim-dap-unity").setup({ enable_unity_cs_configuration = true })

-- Walk up from the current file/cwd to the folder containing `Assets/`, which
-- vstuc wants as projectPath. Falls back to cwd when no Unity project is found.
local function unity_project_root()
	local start = vim.fn.expand("%:p")
	if start == "" then
		start = vim.fn.getcwd()
	end
	local found = vim.fs.find("Assets", { upward = true, type = "directory", path = vim.fs.dirname(start) })[1]
	if found then
		return vim.fs.dirname(found)
	end
	return vim.fn.getcwd()
end

table.insert(dap.configurations.cs, {
	type = "unity",
	name = "attach - remote Unity (IP + Port)",
	request = "attach",
	logFile = vim.fn.stdpath("data") .. "\\vstuc.log",
	projectPath = unity_project_root,
	endPoint = function()
		local ip = vim.fn.input("Unity host IP: ")
		if ip == "" then
			error("remote Unity attach: no IP provided", 0)
		end
		local port = tonumber(vim.fn.input("Unity Port: "))
		if not port then
			error("remote Unity attach: invalid Port", 0)
		end
		return string.format("%s:%d", ip, port)
	end,
})
