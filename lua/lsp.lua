-- lsp

local work_config = require("work_config")

local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("*", {
	root_markers = { ".git", ".svn" },
	capabilities = capabilities,
})
require("mason").setup()
if work_config.enabled then
	local roslyn_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "bin", "lib", "net9.0")

	-- patch roslyn to work with 3dplayer
	local function patch_buildhost_config()
		local cfg = vim.fs.joinpath(
			roslyn_dir,
			"BuildHost-net472",
			"Microsoft.CodeAnalysis.Workspaces.MSBuild.BuildHost.exe.config"
		)
		if vim.fn.filereadable(cfg) == 0 then
			return
		end
		local lines = vim.fn.readfile(cfg)
		local id
		for i, line in ipairs(lines) do
			if line:find('name="System.Threading.Tasks.Extensions"', 1, true) then
				id = i
				break
			end
		end
		if not id then
			return -- redirect already gone; nothing to do
		end
		local first, last = id, id
		while first > 1 and not lines[first]:find("<assemblyBinding", 1, true) do
			first = first - 1
		end
		while last < #lines and not lines[last]:find("</assemblyBinding>", 1, true) do
			last = last + 1
		end
		for _ = first, last do
			table.remove(lines, first)
		end
		vim.fn.writefile(lines, cfg)
	end
	pcall(patch_buildhost_config)

	vim.lsp.config("roslyn", {
		cmd = {
			"dotnet",
			vim.fs.joinpath(roslyn_dir, "Microsoft.CodeAnalysis.LanguageServer.dll"),
			"--logLevel", -- this property is required by the server
			"Information",
			"--extensionLogDirectory", -- this property is required by the server
			vim.fs.joinpath(vim.loop.os_tmpdir(), "roslyn_ls/logs"),
			"--stdio",
		},
		settings = {
			["csharp|inlay_hints"] = {
				csharp_enable_inlay_hints_for_implicit_object_creation = true,
				csharp_enable_inlay_hints_for_implicit_variable_types = true,
			},
			["csharp|code_lens"] = {
				dotnet_enable_references_code_lens = true,
			},
		},
		filetypes = { "cs", "sln", "csproj" },
		root_dir = function(bufnr, on_dir)
			local fname = vim.api.nvim_buf_get_name(bufnr)
			local sln = vim.fs.find(function(name)
				return name:match("%.sln$")
			end, { path = vim.fs.dirname(fname), upward = true, type = "file", limit = 1 })[1]
			if sln then
				on_dir(vim.fs.dirname(sln))
			end
		end,
		on_attach = function(client, _)
			local root = client.config.root_dir
			if not root then
				return
			end
			local sln = vim.fs.find(function(name)
				return name:match("%.sln$")
			end, { path = root, upward = true, type = "file", limit = 1 })[1]
			if sln then
				client:notify("solution/open", { solution = vim.uri_from_fname(sln) })
			end
		end,
	})
	vim.lsp.enable("roslyn")
	require("mason-lspconfig").setup({
		ensure_installed = {
			"rust_analyzer",
			"lua_ls",
			"pyright",
		},
	})
	require("mason-lspconfig").setup_handlers({
		function(server_name) -- default handler (optional)
			require("lspconfig")[server_name].setup({})
		end,
		["lua_ls"] = function()
			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})
		end,
	})
else
	require("mason-lspconfig").setup({
		ensure_installed = {
			"rust_analyzer",
			"gopls",
			"pyright",
			"lua_ls",
		},
	})
	require("mason-lspconfig").setup_handlers({
		function(server_name)
			require("lspconfig")[server_name].setup({})
		end,
	})
end
