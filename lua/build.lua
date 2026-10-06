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
				table.insert(build_actions, { name = name, action = "pushd ..; ./" .. name .. "; popd" })
			end
		end
		vim.cmd("cd " .. cwd)
	-- EPC
	else
		table.insert(build_actions, { name = "EPC", action = "dotnet build GameServer_Kit/Setup/ePC_Kit.sln" })
	end
	vim.ui.select(build_actions, {
		prompt = "Select project to build:",
		format_item = function(item)
			return item.name
		end,
	}, function(choice)
		shell.do_async_cmd_with_window(choice.action, { auto_close = true }, { title = choice.name })
	end)
end

function build.copy()
	local copy_data = {}
	local cwd = vim.fn.getcwd()
	local _, end_pos = string.find(cwd, "3dplayer")
	if end_pos then
		local version = string.match(cwd, "\\(.+)\\", end_pos + 1)
		local remote_base_dir = "/home/cjdev/projects/3dplayer"
		-- Assemblies build output
		local core_assemblies_dir = "../CoreAssemblies"
		local core_presentation_dir = "../CorePresentation"
		for name, _ in vim.fs.dir(core_assemblies_dir) do
			if string.find(name, "BuildOutputCore") then
				table.insert(copy_data, {
					name = name,
					title = string.format("Copy %s to devkit", name),
					user = "cjdev",
					build_output = string.format("%s/%s", core_assemblies_dir, name),
					remote_dir = string.format("%s/%s/CoreBuild/StandardBuild_Data/Managed", remote_base_dir, version),
				})
			end
		end
		-- unity + assemblies build output
		for name, _ in vim.fs.dir(core_presentation_dir) do
			if string.find(name, "CorePresentationLinux") then
				table.insert(copy_data, {
					name = name,
					title = string.format("Copy %s to devkit", name),
					user = "cjdev",
					build_output = string.format("%s/%s", core_presentation_dir, name),
					remote_dir = string.format("%s/%s/CoreBuild", remote_base_dir, version),
				})
			end
		end
	-- EPC
	else
		local remote_base_dir = "/home/player/bin/ePC"
		table.insert(copy_data, {
			name = "EPC Binaries",
			title = "Copy EPC Binaries to devkit",
			user = "root",
			build_output = "GameServer_Kit/Setup/Intermediate",
			remote_dir = string.format("%s", remote_base_dir),
		})
		table.insert(copy_data, {
			name = "SQL Scripts",
			user = "root",
			title = "Copy SQL Scripts to devkit",
			build_output = "Common_Dependencies/SQL",
			remote_dir = string.format("%s/SQL", remote_base_dir),
		})
	end
	vim.ui.select(copy_data, {
		prompt = "Select what to copy:",
		format_item = function(item)
			return item.name
		end,
	}, function(choice)
		local ip = vim.fn.input("Enter IP to copy to: ")
		if ip == "" then
			error("No IP Provided")
		end
		shell.do_async_cmd_with_window(
			string.format("scp -r %s/* %s@%s:%s/", choice.build_output, choice.user, ip, choice.remote_dir),
			{ auto_close = true, pty = true },
			{ title = choice.title }
		)
	end)
end

return build
