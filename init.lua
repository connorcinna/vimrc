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
vim.opt.rtp:append(vim.fn.stdpath "config" .. "C:/Users/ccummings/AppData/Local/nvim/runtime")
vim.api.nvim_set_hl(0, 'LineNrAbove', { fg='#bcbcbc', bold=true })
vim.api.nvim_set_hl(0, 'LineNr', { fg='#bcbcbc', bold=true })
vim.api.nvim_set_hl(0, 'LineNrBelow', { fg='#bcbcbc', bold=true })

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.gruvbox_material_background = 'hard'
vim.cmd [[set relativenumber]]
vim.cmd [[set nohls]]
require("lazy").setup({
  "neovim/nvim-lspconfig",
  'nvim-lua/plenary.nvim',
  'nvim-telescope/telescope.nvim',
  'OmniSharp/omnisharp-vim',
  'Hoffs/omnisharp-extended-lsp.nvim',
  "simrat39/rust-tools.nvim",
  "tpope/vim-repeat",
  {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = true
  },
  "scrooloose/nerdtree",
  "tmhedberg/matchit",
  "mileszs/ack.vim", 
  "sjl/gundo.vim",
  "tpope/vim-dispatch",
  "vim-airline/vim-airline",
  "vim-airline/vim-airline-themes",
  "sainnhe/gruvbox-material",
  "rktjmp/lush.nvim",
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
	  "williamboman/mason-lspconfig.nvim",
	  opt = 
	  {
		  ensure_installed = 
		  {
			  'rust_analyzer',
			  'omnisharp',
		  },
	  },
  },
})
local omnisharp_server_location = vim.fn.has('win32') and 'C:\\omnisharp\\OmniSharp.exe' or '~/omnisharp/omnisharp'
require('lspconfig').omnisharp.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = { omnisharp_server_location, "--languageserver" , "--hostPID", tostring(pid) }
})
--vim.cmd [[let g:OmniSharp_server_path = omnisharp_server_location]]
vim.g['OmniSharp_server_path'] = omnisharp_server_location
vim.cmd [[let g:OmniSharp_server_use_net6 = 1]]
vim.cmd [[let g:airline_theme='minimalist']]
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<Leader>d', ':NERDTreeToggle<CR>', {noremap = true, silent = true, desc = "open nerdtree"})
vim.keymap.set('n', '<Leader>f', builtin.find_files, {noremap = true, silent = true, desc = "telescope find files"})
vim.keymap.set('n', '<Leader>fg', builtin.live_grep, {noremap = true, silent = true, desc = "telescope live grep"})
vim.keymap.set('n', '<Leader>fcw', ':lua require("telescope.builtin").grep_string({search = vim.fn.expand("<cword>")})<CR>', {noremap = true, silent = true, desc = "telescope find current word"})
vim.keymap.set('n', '<C-g>', ':lua vim.lsp.buf.hover()<CR>', {noremap = true, silent = true, desc = "hover actions"})
vim.keymap.set('n', '<C-h>', ':lua vim.lsp.buf.references()<CR>', {noremap = true, silent = true, desc = "find references"})
require('telescope').setup({})
-- colorschemes 
vim.o.background = "dark"
vim.cmd [[colorscheme gruvbox-material]]

vim.cmd [[set shiftwidth=4]]
vim.cmd [[set tabstop=4 ]]
vim.cmd [[set expandtab ]]


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

  -- Set up cmp with lsp
  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  if vim.fn.has('win32') then
      vim.api.nvim_set_current_dir("C:\\SVN_Checkouts\\")
      vim.cmd [[set ffs=dos]]
      vim.o.shell = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
      vim.o.shellcmdflag = '-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues["Out-File:Encoding"]="utf8";Remove-Alias -Force -ErrorAction SilentlyContinue tee;'
      vim.o.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
      vim.o.shellpipe = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
      vim.cmd [[set shellquote= shellxquote=]]


      vim.api.nvim_create_autocmd('TermOpen', {
          callback = function()
              vim.api.nvim_chan_send(vim.bo.channel, "$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'\r")
          end,
      })
  end
