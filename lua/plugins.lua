-- lazy.nvim bootstrap and plugin spec

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	"nvim-lua/plenary.nvim",
	"nvim-telescope/telescope.nvim",
	{
		"seblj/roslyn.nvim",
		ft = "cs",
		opts = {
			broad_search = true,
			file_watching = "roslyn",
		},
	},
	"mfussenegger/nvim-dap",
	"tpope/vim-repeat",
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "mason-org/mason.nvim", opts = {} },
		"neovim/nvim-lspconfig",
	},
	"tmhedberg/matchit",
	{
		"nvim-tree/nvim-tree.lua",
	},
	"mileszs/ack.vim",
	"sjl/gundo.vim",
	"tpope/vim-dispatch",
	"godlygeek/tabular",
	"vim-airline/vim-airline",
	"vim-airline/vim-airline-themes",
	"slugbyte/lackluster.nvim",
	"aikhe/fleur.nvim",
	"rktjmp/lush.nvim",
	"ntpeters/vim-better-whitespace",
	-- snippets and autocomplete
	"L3MON4D3/LuaSnip",
	"saadparwaiz1/cmp_luasnip",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"hrsh7th/nvim-cmp",
	{
		"williamboman/mason.nvim",
		config = true,
	},
	{
		"khoido2003/roslyn-filewatch.nvim",
		config = function()
			require("roslyn_filewatch").setup()
		end,
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
	},
	{
		"stevearc/conform.nvim",
		opts = {},
	},
})

-- nvim-tree config
local config = {
	sync_root_with_cwd = true,
	filesystem_watchers = {
		enable = false,
	},
	auto_reload_on_write = false,
	reload_on_bufenter = true,
	hijack_directories = {
		enable = false,
		auto_open = false,
	},
	tab = {
		sync = {
			open = true,
			close = true,
		},
	},
	git = {
		enable = false,
	},
}
require("nvim-tree").setup(config)
