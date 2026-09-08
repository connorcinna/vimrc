-- keybinds

local work_config = require("work_config")

-- File find keybinds
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<Leader>d", ":NvimTreeToggle<CR>", { noremap = true, silent = true, desc = "toggle tree" })
vim.keymap.set("n", "<Leader>f", builtin.find_files, { noremap = true, silent = true, desc = "telescope find files" })
vim.keymap.set("n", "<Leader>fg", builtin.live_grep, { noremap = true, silent = true, desc = "telescope live grep" })
vim.keymap.set(
	"n",
	"<Leader>fb",
	builtin.current_buffer_fuzzy_find,
	{ noremap = true, silent = true, desc = "telescope fuzzy find current buffer" }
)
vim.keymap.set(
	"n",
	"<Leader>fcw",
	':lua require("telescope.builtin").grep_string({search = vim.fn.expand("<cword>")})<CR>',
	{ noremap = true, silent = true, desc = "telescope find current word" }
)
require("telescope").setup({})

-- LSP Keybinds
vim.keymap.set(
	"n",
	"<Leader>lh",
	":lua vim.diagnostic.open_float()<CR>",
	{ noremap = true, silent = true, desc = "diagnostics popup" }
)
vim.keymap.set(
	"n",
	"<Leader>li",
	":lua vim.lsp.buf.hover()<CR>",
	{ noremap = true, silent = true, desc = "hover actions" }
)
vim.keymap.set(
	"n",
	"<Leader>lr",
	":lua vim.lsp.buf.references()<CR>",
	{ noremap = true, silent = true, desc = "find references" }
)
vim.keymap.set(
	"n",
	"<Leader>ld",
	":lua vim.lsp.buf.implementation()<CR>",
	{ noremap = true, silent = true, desc = "go to implementation" }
)
vim.keymap.set("n", "<Leader>ln", ":lua vim.lsp.buf.rename()<CR>", { noremap = true, silent = true, desc = "rename" })

-- copy full path of current file to external clipboard
vim.keymap.set("n", "<Leader>yp", function()
	vim.fn.setreg("+", vim.fn.expand("%:p:."))
end)

-- copy full path current directory to external clipboard
local function getcwd()
	if vim.fn.has("win32") then
		return vim.system({ "powershell.exe", "-NoProfile", "-Command", "pwd | Select-Object -ExpandProperty Path" })
			:wait().stdout
	else
		return vim.fn.expand("%:h")
	end
end
vim.keymap.set("n", "<Leader>yd", function()
	local pwd = getcwd()
	vim.fn.setreg("+", pwd)
end)

-- copy current filename open without extension
vim.keymap.set("n", "<Leader>yn", function()
	vim.fn.setreg("+", vim.fn.expand("%:t:r"))
end)

-- close tab
vim.keymap.set("n", "<Leader>tc", ":tabclose!<CR>", { noremap = true, silent = true, desc = "tab close" })
-- new tab
vim.keymap.set("n", "<Leader>tn", ":tabnew<CR>", { noremap = true, silent = true, desc = "tab new" })
-- open new tab with init.lua and change directory to it
vim.keymap.set("n", "<Leader>oc", function()
	vim.cmd("tabnew")
	vim.cmd("tcd " .. vim.fs.dirname(vim.env.MYVIMRC))
	vim.cmd("edit " .. vim.env.MYVIMRC)
end, { noremap = true, silent = true, desc = "open configuration dir" })

-- build work projects
if work_config.enabled then
	local build = require("build")
	vim.keymap.set("n", "<Leader>b", function()
		build.run()
	end, { noremap = true, silent = true, desc = "build work projects" })
end
