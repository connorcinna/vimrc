-- build work projects and scp the output to a devkit

local build = {}

local shell = require("shell")
local util = require("util")

local build_output
local remote_destination

local function is_presentation_modified()
	local status = shell.do_system_cmd("svn status ../CorePresentation")
	for line in status:gmatch("[^\r\n]+") do
		if line:match("^M%s+") then
			return true
		end
	end
	return false
end

local function callback()
	vim.schedule(function()
		vim.ui.input({ prompt = "Build Succeeded! SCP to devkit? (y/n)" }, function(confirm)
			if confirm == "y" then
				vim.ui.input({ prompt = "Enter IP address: " }, function(ip)
					if string.find(remote_destination, "cjdev") ~= nil then
						remote_destination = "cjdev@" .. ip .. ":" .. remote_destination
					else
						remote_destination = "root@" .. ip .. ":" .. remote_destination
					end
					shell.do_async_cmd("scp -vr " .. build_output .. " " .. remote_destination)
				end)
			end
		end)
	end)
end

function build.run()
	local dir_split = util.tokenize(vim.fn.getcwd(), "\\")
	for key, value in pairs(dir_split) do
		if string.find(value, "C2") ~= nil then
			vim.schedule(function()
				local script_name = ""
				if is_presentation_modified() then
					vim.notify("Building C2 CorePresentation + CoreAssemblies")
					build_output = "../CorePresentation/CorePresentationLinuxDebug/*"
					remote_destination = "/home/cjdev/projects/3dplayer/" .. value .. "/CoreBuild/"
					script_name = "CIIBuildCoreLinuxDevelopment64Bit.bat"
				else
					vim.notify("Building C2 CoreAssemblies only")
					build_output = "../CoreAssemblies/BuildOutputCoreDevelopmentCII/*"
					remote_destination = "/home/cjdev/projects/3dplayer/"
						.. value
						.. "/CoreBuild/StandardBuild_Data/Managed/"
					script_name = "CIIBuildDevelopment64Bit.bat"
				end
				shell.do_async_cmd("pushd ..; ./" .. script_name .. "; popd", callback)
			end)
			break
		elseif string.find(value, "C3") ~= nil then
			vim.schedule(function()
				vim.notify("Building C3")
				local script_name = ""
				if is_presentation_modified() then
					build_output = "../CorePresentation/CorePresentationLinuxDebug/*"
					remote_destination = "/home/cjdev/projects/3dplayer/" .. value .. "/CoreBuild/"
					script_name = "BuildCoreLinuxDevelopment64Bit.bat"
				else
					build_output = "../CoreAssemblies/BuildOutputCoreDevelopment/*"
					remote_destination = "/home/cjdev/projects/3dplayer/"
						.. value
						.. "/CoreBuild/StandardBuild_Data/Managed/"
					script_name = "BuildDevelopment64Bit.bat"
				end
				shell.do_async_cmd("pushd ..; ./ " .. script_name .. "; popd", callback)
			end)
			break
		elseif string.find(value, "ETabs") ~= nil then
			vim.schedule(function()
				vim.notify("Building ETabs")
				local script_name = ""
				if is_presentation_modified() then
					build_output = "../CorePresentation/CorePresentationLinuxDebug/*"
					remote_destination = "/home/cjdev/projects/3dplayer/" .. value .. "/CoreBuild/"
					script_name = "ETabsBuildCoreLinuxDevelopment64Bit.bat"
				else
					build_output = "../CoreAssemblies/BuildOutputCoreDevelopment/*"
					remote_destination = "/home/cjdev/projects/3dplayer/"
						.. value
						.. "/CoreBuild/StandardBuild_Data/Managed/"
					script_name = "ETabsBuildDevelopment64Bit.bat"
				end
				shell.do_async_cmd("pushd ..; ./ " .. script_name .. "; popd", callback)
			end)
			break
		elseif string.find(value, "EPC") ~= nil then
			vim.schedule(function()
				vim.notify("Building EPC")
				build_output = "./GameServer_Kit/Setup/Intermediate/*"
				remote_destination = "/home/player/bin/ePC/"
			end)
			shell.do_async_cmd("dotnet build .\\GameServer_Kit\\Setup\\ePC_Kit.sln", callback)
			break
		end
		util.print("Could not identify project directory: " .. vim.fn.getcwd())
	end
end

return build
