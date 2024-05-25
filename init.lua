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

vim.api.nvim_set_hl(0, 'LineNrAbove', { fg='#bcbcbc', bold=true })
vim.api.nvim_set_hl(0, 'LineNr', { fg='#bcbcbc', bold=true })
vim.api.nvim_set_hl(0, 'LineNrBelow', { fg='#bcbcbc', bold=true })

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.gruvbox_material_background = 'hard'
vim.cmd [[set relativenumber]]
vim.cmd [[set nohls]]

require("lazy").setup({
  "neovim/nvim-lspconfig",
  "simrat39/rust-tools.nvim",
  "tpope/vim-repeat",
  "tmsvg/pear-tree",
  "scrooloose/nerdtree",
  "tmhedberg/matchit",
  "mileszs/ack.vim", 
  "sjl/gundo.vim",
  "tpope/vim-dispatch",
  "vim-airline/vim-airline",
  "vim-airline/vim-airline-themes",
--  "ellisonleao/gruvbox.nvim",
  "sainnhe/gruvbox-material",
  "t184256/vim-boring",
  "rktjmp/lush.nvim",
  "fxn/vim-monochrome",
  -- snippets and autocomplete
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "hrsh7th/nvim-cmp",
})
vim.cmd [[let g:airline_theme='minimalist']]
vim.keymap.set('n', '<Leader>d', ':NERDTreeToggle<CR>', {noremap = true, silent = true, desc = "open nerdtree"})
vim.keymap.set('n', '<Leader>f', ':Ack!<Space>', {noremap = true, silent = true, desc = "run Ack"})
vim.keymap.set('n', '<C-d>', ':lua vim.lsp.buf.hover()<CR>', {noremap = true, silent = true, desc = "hover actions"})
-- lsp configs
local rt = require("rust-tools")
rt.setup({
    server = {
        on_attach = function(_, bufnr)
            vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
        require("rust-tools").inlay_hints.enable()
    end,
    },
    lazy=false,
})

-- colorschemes 
vim.o.background = "dark"
vim.cmd [[colorscheme gruvbox-material]]
-- vim.cmd [[colorscheme monochrome]]
--vim.cmd [[colorscheme boring]]
--vim.cmd [[colorscheme warlock]]

vim.cmd [[set shiftwidth=4]]
vim.cmd [[set tabstop=4 ]]

local cmp = require'cmp'

cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<Tab>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      { name = 'luasnip' }, -- For luasnip users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
  })

  -- Set up lspconfig.
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  vim.lsp.set_log_level("trace")
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  require('lspconfig')['clangd'].setup {
    capabilities = capabilities
  }
