-- build work projects

local build = {}
local shell = require("shell")

function build.run()
	local cwd = vim.fn.getcwd()
	local build_actions = {}
	-- 3dplayer
	if string.find(cwd, "3dplayer") ~= nil then
		vim.cmd("cd ..")
		for name, _ in vim.fs.dir(vim.fn.getcwd()) do
			if string.find(name, ".bat") ~= nil then
				table.insert(build_actions, "pushd ..; ./" .. name .. "; popd")
			end
		end
		vim.cmd("cd " .. cwd)
	-- EPC
	else
		table.insert(build_actions, "dotnet build GameServer_Kit/Setup/ePC_Kit.sln")
	end
	vim.ui.select(build_actions, {
		prompt = "Select project to build:",
	}, function(choice)
		shell.do_async_cmd_with_window(choice, { auto_close = true })
	end)
end

return build
