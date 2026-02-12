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
local work = False

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.gruvbox_material_background = 'hard'
vim.cmd [[set relativenumber]]
vim.cmd [[set nohls]]
vim.cmd [[set noea]]
vim.cmd [[set nobomb]]
require("lazy").setup({
  "neovim/nvim-lspconfig",
  'nvim-lua/plenary.nvim',
  'nvim-telescope/telescope.nvim',
   {
       "seblj/roslyn.nvim",
       ft = "cs",
       opts = {
           broad_search = true,
       }
   },
  "mfussenegger/nvim-dap",
  "tpope/vim-repeat",
  {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = true
  },
  {
	  "mason-org/mason.nvim",
	  opts = {}
  },
  "scrooloose/nerdtree",
  "tmhedberg/matchit",
  "mileszs/ack.vim",
  "sjl/gundo.vim",
  "tpope/vim-dispatch",
  "godlygeek/tabular",
  "vim-airline/vim-airline",
  "vim-airline/vim-airline-themes",
  "sainnhe/gruvbox-material",
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
	  "williamboman/mason-lspconfig.nvim",
	  opt =
	  {
		  ensure_installed =
		  {
			  'rust-analyzer',
		  },
	  },
  },
})

-- swap to cmd.exe to do a command and then back to powershell
local function do_redirect_shell_cmd(args)
    vim.o.shell="C:\\Windows\\System32\\cmd.exe"
    vim.cmd(args)
    vim.o.shell= "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
end

local function find_dotnet_project_dir()
  local uv = vim.loop
  local cwd = vim.fn.getcwd()

  -- Helper to check if a directory contains a .sln or .csproj file
  local function contains_dotnet_file(dir)
    local full_path = cwd .. "/" .. dir
    local handle = uv.fs_scandir(full_path)
    if not handle then return false end

    while true do
      local name, type = uv.fs_scandir_next(handle)
      if not name then break end
      if type == "file" and (name:match("%.sln$") or name:match("%.csproj$")) then
        return true
      end
    end
    return false
  end

  -- Scan subdirectories of cwd
  local handle = uv.fs_scandir(cwd)
  if not handle then return nil end

  while true do
    local name, type = uv.fs_scandir_next(handle)
    if not name then break end
    if type == "directory" and contains_dotnet_file(name) then
      return name
    end
  end

  return nil -- nothing found
end

local function find_clangd_json()
  local uv = vim.loop
  local cwd = vim.fn.getcwd()

  -- Helper to check if a directory contains a compile_commands.json file
  local function contains_compile_commands_json(dir)
    local full_path = cwd .. "/" .. dir
    local handle = uv.fs_scandir(full_path)
    if not handle then return false end

    while true do
      local name, type = uv.fs_scandir_next(handle)
      if not name then break end
      if type == "file" and (name:match("compile_commands.json")) then
        return true
      end
    end
    return false
  end

  -- Scan subdirectories of cwd
  local handle = uv.fs_scandir(cwd)
  if not handle then return nil end

  while true do
    local name, type = uv.fs_scandir_next(handle)
    if not name then break end
    if type == "directory" and contains_compile_commands_json(name) then
      return name
    end
  end
  return nil -- nothing found
end

require("mason-lspconfig").setup({
    ensure_installed = {
        "rust_analyzer",
    },
})

-- require("mason-lspconfig").setup_handlers({
--     function(server_name)
--         require("lspconfig")[server_name].setup({
--             on_attach = on_attach,
--             capabilities = capabilities,
--             handlers = rounded_border_handlers,
--         })
--     end,
--     ["rust_analyzer"] = function()
--         require("lspconfig")["rust_analyzer"].setup({
--             on_attach = on_attach,
--             capabilities = capabilities,
--         })
--     end,
--     ["clangd"] = function()
--         require("lspconfig")["clangd"].setup({
--             on_attach = on_attach,
--             capabilities = capabilities,
--         })
-- 	end,
--     ["omnisharp"] = function()
--         require("lspconfig")["omnisharp"].setup({
--             on_attach = on_attach,
--             capabilities = capabilities,
--             enable_import_completion = true,
--             organize_imports_on_format = true,
--             enable_roslyn_analyzers = true,
--             root_dir = find_dotnet_project_dir(),
--         })
--     end,
-- })
vim.cmd [[let g:airline_theme='minimalist']]
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<Leader>d', ':NERDTreeToggle<CR>', {noremap = true, silent = true, desc = "open nerdtree"})
vim.keymap.set('n', '<Leader>f', builtin.find_files, {noremap = true, silent = true, desc = "telescope find files"})
vim.keymap.set('n', '<Leader>fg', builtin.live_grep, {noremap = true, silent = true, desc = "telescope live grep"})
vim.keymap.set('n', '<Leader>fb', builtin.current_buffer_fuzzy_find, {noremap = true, silent = true, desc = "telescope fuzzy find current buffer"})
vim.keymap.set('n', '<Leader>fcw', ':lua require("telescope.builtin").grep_string({search = vim.fn.expand("<cword>")})<CR>', {noremap = true, silent = true, desc = "telescope find current word"})
vim.keymap.set('n', '<Leader>r', ':lua vim.diagnostic.open_float()<CR>', {noremap = true, silent = true, desc = "diagnostics popup"})
vim.keymap.set('n', '<C-g>', ':lua vim.lsp.buf.hover()<CR>', {noremap = true, silent = true, desc = "hover actions"})
vim.keymap.set('n', '<C-h>', ':lua vim.lsp.buf.references()<CR>', {noremap = true, silent = true, desc = "find references"})
vim.keymap.set('n', 'gd', ':lua vim.lsp.buf.implementation()<CR>', {noremap = true, silent = true, desc = "go to implementation"})
vim.keymap.set('n', '<Leader>yp', function()
    vim.fn.setreg('+', vim.fn.expand('%:p:.'))
end)
vim.keymap.set('n', '<Leader>yd', function()
    vim.fn.setreg('+', vim.fn.expand('%:h'))
end)
vim.keymap.set('n', '<Leader>yn', function()
    vim.fn.setreg('+', vim.fn.expand('%:t:r'))
end)
require('telescope').setup({})
-- colorschemes
vim.o.background = "dark"
vim.cmd [[colorscheme fleur]]

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
	vim.o.shell = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -NoLogo -NoProfile"
	vim.cmd [[set ffs=dos]]
	vim.cmd [[set shellquote= shellxquote=]]
	if work then
		-- the following line doesn't need to have the forward slashes swapped for some reason?
		vim.opt.rtp:append(vim.fn.stdpath "config" .. "C:/Users/ccummings/AppData/Local/nvim/runtime")
		vim.env.TEMP = "C:\\Users\\ccummings\\AppData\\Local\\Temp"
	        vim.api.nvim_set_current_dir("C:\\projects\\")
		--DIY powershell profile.. avert your eyes
		 vim.api.nvim_create_autocmd('TermOpen', {
		      callback = function()
			  vim.api.nvim_chan_send(vim.bo.channel, "$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'\r")
			  vim.api.nvim_chan_send(vim.bo.channel, "Set-Alias -Name grep -Value rg\r")
			  vim.api.nvim_chan_send(vim.bo.channel, "function svndiff\r\n {\r\n param([string]$DiffPath,[string]$Revision)\r\n $Command = 'svn diff -x --ignore-eol-style --patch-compatible'\r\n if ($Revision)\r\n {\r\n $Revisions = $Revision.Split(':')\r\n if (!$Revisions[0] -or !$Revisions[1])\r\n {\r\n echo 'please provide -Revision as an argument in the form \"REVISION1:REVISION2\"'\r\n }\r\n $Command = $('svn diff -r ' + $Revision + ' -x --ignore-eol-style --patch-compatible') \r\n }\r\n if ($DiffPath)\r\n {\r\n $Temp = New-TemporaryFile\r\n $OutFile = $($pwd.Path + '\\' + $DiffPath)\r\n $Command = $($Command + ' > ' + $Temp)\r\n echo $Command\r\n Invoke-Expression $Command\r\n $Content = [IO.File]::ReadAllLines($Temp)\r\n [IO.File]::WriteAllLines($OutFile,$Content)}\r\n else\r\n {\r\n echo $Command\r\n Invoke-Expression $Command\r\n }\r\n }\r")
			   vim.api.nvim_chan_send(vim.bo.channel, "clear\r")
		      end, --autocmd callback function
		    })
		    vim.api.nvim_create_user_command('SvnBlame', function()
			do_redirect_shell_cmd("new | r ! svn blame #")
		    end, {})
		    local dap = require('dap')
		    dap.adapters.coreclr = {
			type = "executable",
			command = "C:\\Users\\ccummings\\AppData\\Local\\nvim-data\\mason\\packages\\netcoredbg\\netcoredbg\\netcoredbg.exe",
			args = { "--interpreter=vscode" },
		    }
		    dap.configurations.cs = {
			type = "coreclr",
			name = "launch - netcoredbg",
			request = "launch",
			program = function()
			    return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/GameServer_Kit/Setup/Intermediate/', 'file')
			end,
		    }
       end
end
