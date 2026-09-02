-- general vim options and appearance settings that don't depend on plugins

vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#bcbcbc", bold = true })
vim.api.nvim_set_hl(0, "LineNr", { fg = "#bcbcbc", bold = true })
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#bcbcbc", bold = true })

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.cmd([[set relativenumber]])
vim.cmd([[set nohls]])
vim.cmd([[set noea]])
vim.cmd("filetype plugin indent on")
vim.cmd([[hi clear MatchParen]])
vim.cmd([[let g:airline_theme='minimalist']])
vim.o.background = "dark"
vim.opt.autoindent = true
vim.o.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.o.background = "dark"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.cmd([[set shiftwidth=4]])
vim.cmd([[set tabstop=4 ]])
vim.cmd([[set expandtab ]])
