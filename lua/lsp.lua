-- lsp

local work_config = require("work_config")

local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("*", {
	root_markers = { ".git", ".svn" },
	capabilities = capabilities,
})
require("mason").setup()
if work_config.enabled then
	vim.lsp.config("roslyn", {
		cmd = {
			"dotnet",
			"C:\\Users\\ccummings\\AppData\\Local\\nvim\\bin\\lib\\net9.0\\Microsoft.CodeAnalysis.LanguageServer.dll",
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
		root_dir = vim.fs.dirname(vim.fs.find(function(name, path)
			return name:match(".sln")
		end, { limit = math.huge, type = "file" })[1]),
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
