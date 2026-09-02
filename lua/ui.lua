-- config that has to happen after packages are loaded

vim.cmd([[colorscheme lackluster]])

local bufferline = require("bufferline")
bufferline.setup({
	options = {
		mode = "tabs",
		style_preset = bufferline.style_preset.default,
	},
})
