-- keybinds

local tree = require("nvim-tree.api").tree
vim.keymap.set("n", "<Leader>to", function()
	tree.open()
end, { noremap = true, silent = true, desc = "focus tree" })
vim.keymap.set("n", "<Leader>tt", function()
	tree.toggle({ find_file = false, update_root = false, focus = true })
end, { noremap = true, silent = true, desc = "toggle tree" })
vim.keymap.set("n", "<Leader>tf", function()
	tree.find_file({ open = true, focus = true })
end, { noremap = true, silent = true, desc = "tree find file" })

-- LSP Keybinds
vim.keymap.set("n", "<Leader>lh", function()
	vim.diagnostic.open_float()
end, { noremap = true, silent = true, desc = "diagnostics popup" })
vim.keymap.set("n", "<Leader>lo", function()
	vim.lsp.buf.hover()
end, { noremap = true, silent = true, desc = "hover actions" })
vim.keymap.set("n", "<Leader>lr", function()
	vim.lsp.buf.references()
end, { noremap = true, silent = true, desc = "find references" })
vim.keymap.set("n", "<Leader>ld", function()
	vim.lsp.buf.definition()
end, { noremap = true, silent = true, desc = "go to implementation" })
vim.keymap.set("n", "<Leader>li", function()
	vim.lsp.buf.implementation()
end, { noremap = true, silent = true, desc = "go to implementation" })
vim.keymap.set("n", "<Leader>ln", function()
	vim.lsp.buf.rename()
end, { noremap = true, silent = true, desc = "rename" })
vim.keymap.set("n", "<Leader>lne", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { noremap = true, silent = true, desc = "goto next error" })
vim.keymap.set("n", "<Leader>lpe", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { noremap = true, silent = true, desc = "goto last error" })

-- useful file expansion keybinds

vim.keymap.set("n", "<Leader>yp", function()
	vim.fn.setreg("+", vim.fn.expand("%:p:."))
end, { desc = "copy full path of current file to external clipboard" })

local function getcwd()
	if vim.fn.has("win32") == 1 then
		return vim.system({ "powershell.exe", "-NoProfile", "-Command", "pwd | Select-Object -ExpandProperty Path" })
			:wait().stdout
	else
		return vim.fn.expand("%:h")
	end
end

vim.keymap.set("n", "<Leader>yd", function()
	local pwd = getcwd()
	vim.fn.setreg("+", pwd)
end, { desc = "copy current working directory" })

vim.keymap.set("n", "<Leader>yn", function()
	vim.fn.setreg("+", vim.fn.expand("%:t:r"))
end, { desc = "copy current filename open without extension" })

-- tab page management

vim.keymap.set("n", "<Leader>tc", ":tabclose!<CR>", { noremap = true, silent = true, desc = "close tab" })

vim.keymap.set("n", "<Leader>tn", function()
	vim.api.nvim_open_tabpage(0, true, { after = -1 })
	require("alpha").start()
end, { noremap = true, silent = true, desc = "new tab" })

vim.keymap.set("n", "<Leader>oc", function()
	vim.cmd("tabnew")
	vim.cmd("tcd " .. vim.fs.dirname(vim.env.MYVIMRC))
	vim.cmd("edit " .. vim.env.MYVIMRC)
end, { noremap = true, silent = true, desc = "open configuration dir" })

-- work keybinds

if WorkConfig.enabled then
	-- build work projects
	local build = require("build")
	vim.keymap.set("n", "<Leader>b", function()
		build.run()
	end, { noremap = true, silent = true, desc = "build work projects" })
	vim.keymap.set("n", "<Leader>bc", function()
		build.copy()
	end, { noremap = true, silent = true, desc = "copy work projects" })
	-- open unity, assuming the cwd is CorePresentation
	vim.keymap.set("n", "<Leader>u", function()
		vim.system({
			"powershell.exe",
			"-NoProfile",
			"-Command",
			"start ../CorePresentation/Assets/CorePresentation.unity",
		})
	end, { noremap = true, silent = true, desc = "open Unity project" })
end

-- debugging
local dap = require("dap")
vim.keymap.set("n", "<F5>", function()
	dap.continue()
end, { desc = "Debug: Start/Continue" })
vim.keymap.set("n", "<F10>", function()
	dap.step_over()
end, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F11>", function()
	dap.step_into()
end, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<F12>", function()
	dap.step_out()
end, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<F1>", function()
	dap.toggle_breakpoint()
end, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<Leader>du", function()
	require("dapui").toggle()
end, { desc = "Dap UI" })

-- generic commands, not keybinds

vim.api.nvim_create_user_command("WipeUnlisted", function()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if not vim.bo[bufnr].buflisted then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end
end, {})
