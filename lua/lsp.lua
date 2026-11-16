local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("*", {
	root_markers = { ".git", ".svn" },
	capabilities = capabilities,
})
if WorkConfig.enabled then
	local roslyn_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages", "roslyn", "libexec")

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
		filetypes = { "cs", "solution", "csproj" },
		root_markers = { ".sln", ".svn", ".csproj" },
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
end
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})
vim.lsp.config("intelephense", {
	settings = {
		intelephense = {
			root_markers = { ".svn", ".git" },
		},
	},
})
vim.lsp.config("pyright", {
	settings = {
		pyright = {
			root_markers = { ".svn", ".git" },
		},
		python = {
			analysis = {
				strictParameterNoneValue = false,
				diagnosticSeverityOverrides = {
					reportOperatorIssue = false,
					reportArgumentType = false,
					reportInvalidTypeArguments = false,
					reportPossiblyUnboundVariable = false,
					reportOptionalMemberAccess = false,
				},
			},
		},
	},
})
vim.lsp.enable("lua_ls")
vim.lsp.enable("intelephense")
vim.lsp.enable("pyright")
