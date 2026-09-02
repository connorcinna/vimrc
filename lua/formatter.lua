-- formatter

local work_config = require("work_config")

local my_python_cmd = "python"
local my_python_args = { "-m", "black", "-q", "-" }

if work_config.enabled then
	my_python_cmd = "cmd.exe"
	my_python_args = { "/c", "python", "-m", "black", "-q", "-" }
end
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "my_python" },
	},
	formatters = {
		my_python = {
			command = my_python_cmd,
			args = my_python_args,
			stdin = true,
		},
	},
	format_on_save = {
		timeout_ms = 2000,
		lsp_format = "fallback",
	},
})
