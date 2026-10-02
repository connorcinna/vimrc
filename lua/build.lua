-- build work projects

local build = {}
local shell = require("shell")

function build.run()
	local cwd = vim.fn.getcwd()
	local build_actions = {}
	-- 3dplayer
	if string.find(cwd, "3dplayer") then
		vim.cmd("cd ..")
		for name, _ in vim.fs.dir(vim.fn.getcwd()) do
			if string.find(name, ".bat") then
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

function build.copy()
	local COREASSEMBLIES = "Core Assemblies"
	local COREASSEMBLIESCII = "Core Assemblies CII"
	local COREASSEMBLIESHHR = "Core Assemblies HHR"
	local COREASSEMBLIESETABS = "Core Assemblies ETABS"
	local COREFULL = "Core Presentation + Core Assemblies"
	local EPC = "EPC binaries"
	local SQL = "SQL Scripts"
	local copy_actions = {}
	local version
	local remote_base_dir
	local user
	local cwd = vim.fn.getcwd()
	local _, end_pos = string.find(cwd, "3dplayer")
	if end_pos then
		user = "cjdev"
		version = string.match(cwd, "\\(.+)\\", end_pos + 1)
		remote_base_dir = "/home/cjdev/projects/3dplayer"
		--TODO only insert the build directories that actually exist
		table.insert(copy_actions, COREFULL)
		table.insert(copy_actions, COREASSEMBLIES)
		table.insert(copy_actions, COREASSEMBLIESCII)
		table.insert(copy_actions, COREASSEMBLIESHHR)
		table.insert(copy_actions, COREASSEMBLIESETABS)
	-- EPC
	else
		user = "root"
		remote_base_dir = "/home/player/bin/ePC"
		table.insert(copy_actions, EPC)
		table.insert(copy_actions, SQL)
	end
	vim.ui.select(copy_actions, {
		prompt = "Select what to copy:",
	}, function(choice)
		local remote_dir
		local build_output
		if choice == COREASSEMBLIES then
			remote_dir = string.format("%s/%s/CoreBuild/StandardBuild_Data/Managed", remote_base_dir, version)
			build_output = "../CoreAssemblies/BuildOutputCoreDevelopment/*"
		elseif choice == COREASSEMBLIESCII then
			remote_dir = string.format("%s/%s/CoreBuild/StandardBuild_Data/Managed", remote_base_dir, version)
			build_output = "../CoreAssemblies/BuildOutputCoreDevelopmentCII/*"
		elseif choice == COREASSEMBLIESHHR then
			remote_dir = string.format("%s/%s/CoreBuild/StandardBuild_Data/Managed", remote_base_dir, version)
			build_output = "../CoreAssemblies/BuildOutputCoreDevelopmentHHR/*"
		elseif choice == COREASSEMBLIESETABS then
			remote_dir = string.format("%s/%s/CoreBuild/StandardBuild_Data/Managed", remote_base_dir, version)
			build_output = "../CoreAssemblies/BuildOutputCoreDevelopmentETabs/*"
		elseif choice == COREFULL then
			remote_dir = string.format("%s/%s/CoreBuild", remote_base_dir, version)
			build_output = "../CorePresentation/CorePresentationLinuxDebug/*"
		elseif choice == EPC then
			remote_dir = string.format("%s", remote_base_dir)
			build_output = "GameServer_Kit/Setup/Intermediate/*"
		elseif choice == SQL then
			remote_dir = string.format("%s/SQL", remote_base_dir)
			build_output = "Common_Dependencies/SQL/*"
		end
		local ip = vim.fn.input("Enter IP to copy to: ")
		if ip == "" then
			error("No IP Provided")
		end
		shell.do_async_cmd_with_window(
			string.format("scp -rv %s %s@%s:%s", build_output, user, ip, remote_dir),
			{ auto_close = true }
		)
	end)
end

return build
