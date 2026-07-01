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
vim.cmd [[set noea]]
vim.cmd('filetype plugin indent on')
vim.opt.autoindent = true
vim.o.clipboard = "unnamedplus"

local function paste()
  return {
    vim.fn.split(vim.fn.getreg(""), "\n"),
    vim.fn.getregtype(""),
  }
end

vim.g.clipboard = {
  name = "OSC 52",

  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = paste,
    ["*"] = paste,
  },
}
vim.cmd [[hi clear MatchParen]]

require("lazy").setup({
  "neovim/nvim-lspconfig",
  'nvim-lua/plenary.nvim',
  'nvim-telescope/telescope.nvim',
   {
       "seblj/roslyn.nvim",
       ft = "cs",
       opts = {
           broad_search = true,
           file_watching = "roslyn",
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
  {
    "khoido2003/roslyn-filewatch.nvim",
    config = function()
      require("roslyn_filewatch").setup()
    end,
  },
})

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

local work_config = require('work_config')
vim.lsp.config('*', {
    root_markers = { '.git', '.svn' },
    capabilities = capabilities,
})
if vim.fn.has('win32') == 0 then
    require("mason").setup()
    require("mason-lspconfig").setup({
        ensure_installed = {
            "rust_analyzer",
            "pyright",
            "gopls"
        },
    })
    vim.lsp.enable({"pyright"})
    vim.lsp.enable({"gopls"})
else
    if work_config.enabled then
        vim.lsp.config("roslyn", {
            cmd = {
              'dotnet',
              'C:\\Users\\ccummings\\AppData\\Local\\nvim\\bin\\lib\\net9.0\\Microsoft.CodeAnalysis.LanguageServer.dll',
              '--logLevel', -- this property is required by the server
              'Information',
              '--extensionLogDirectory', -- this property is required by the server
              vim.fs.joinpath(vim.loop.os_tmpdir(), 'roslyn_ls/logs'),
              '--stdio',
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
            filetypes = { 'cs', 'sln', 'csproj' },
            root_dir = vim.fs.dirname(vim.fs.find(function(name, path)
                           return name:match(".sln")
                       end, { limit = math.huge, type = 'file' })[1]),
        })
        vim.lsp.enable('roslyn')
    end
end

vim.cmd [[let g:airline_theme='minimalist']]
-- File find keybinds
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<Leader>d', ':NERDTreeToggle<CR>', {noremap = true, silent = true, desc = "open nerdtree"})
vim.keymap.set('n', '<Leader>f', builtin.find_files, {noremap = true, silent = true, desc = "telescope find files"})
vim.keymap.set('n', '<Leader>fg', builtin.live_grep, {noremap = true, silent = true, desc = "telescope live grep"})
vim.keymap.set('n', '<Leader>fb', builtin.current_buffer_fuzzy_find, {noremap = true, silent = true, desc = "telescope fuzzy find current buffer"})
vim.keymap.set('n', '<Leader>fcw', ':lua require("telescope.builtin").grep_string({search = vim.fn.expand("<cword>")})<CR>', {noremap = true, silent = true, desc = "telescope find current word"})
require('telescope').setup({})
-- LSP Keybinds
vim.keymap.set('n', '<Leader>lh', ':lua vim.diagnostic.open_float()<CR>', {noremap = true, silent = true, desc = "diagnostics popup"})
vim.keymap.set('n', '<Leader>li', ':lua vim.lsp.buf.hover()<CR>', {noremap = true, silent = true, desc = "hover actions"})
vim.keymap.set('n', '<Leader>lr', ':lua vim.lsp.buf.references()<CR>', {noremap = true, silent = true, desc = "find references"})
vim.keymap.set('n', '<Leader>ld', ':lua vim.lsp.buf.implementation()<CR>', {noremap = true, silent = true, desc = "go to implementation"})
vim.keymap.set('n', '<Leader>ln', ':lua vim.lsp.buf.rename()<CR>', {noremap = true, silent = true, desc = "rename"})
-- copy full path of current file to external clipboard
vim.keymap.set('n', '<Leader>yp', function()
    vim.fn.setreg('+', vim.fn.expand('%:p:.'))
end)
-- copy full path current directory to external clipboard
vim.keymap.set('n', '<Leader>yd', function()
    vim.fn.setreg('+', vim.fn.expand('%:h'))
end)
-- copy current filename open without extension
vim.keymap.set('n', '<Leader>yn', function()
    vim.fn.setreg('+', vim.fn.expand('%:t:r'))
end)
local ls = require("luasnip")
-- LuaSnip snippet for C# XML documentation comments
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

ls.add_snippets("cs", {
  s("///", {
    t("/// <summary>"), t({"", "/// "}), i(1, "Description"), t({"", "/// </summary>"}),
    -- Add <param> or <returns> dynamically if needed
    t({"", "/// <param name=\""}), i(2, "param"), t("\">"), i(3, "Description"), t("</param>"),
    t({"", "/// <returns>"}), i(4, "void"), t("</returns>"),
  }),
})

ls.add_snippets("cs", {
  s("///", {
    t("/// <summary>"), t({"", "/// "}), i(1, "Description"), t({"", "/// </summary>"}),
    -- Add <param> or <returns> dynamically if needed
    t({"", "/// <param name=\""}), i(2, "param"), t("\">"), i(3, "Description"), t("</param>"),
    t({"", "/// <returns>"}), i(4, "void"), t("</returns>"),
  }),
})

ls.add_snippets("cs", {
  s("seealso", {
    t('<seealso href="link"/>')
  }),
})

ls.add_snippets("cs", {
  s("inheritdoc", {
    t('/// <inheritdoc/>')
  }),
})

ls.add_snippets("cs", {
  s("///desc", {
    t("/// <summary>"), t({"", "/// "}), i(1, "Description"), t({"", "/// </summary>"}),
  }),
})

vim.o.background = "dark"
vim.cmd [[colorscheme lackluster]]

vim.cmd [[set shiftwidth=4]]
vim.cmd [[set tabstop=4 ]]
vim.cmd [[set expandtab ]]


require('svn')
local cmp = require'cmp'

cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      end,
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-j>'] = cmp.mapping.select_next_item(),
      ['<C-k>'] = cmp.mapping.select_prev_item(),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
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

if vim.fn.has('win32') == 1 then
	vim.o.shell = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -NoLogo -NoProfile"
	vim.cmd [[set ffs=dos]]
	vim.cmd [[set shellquote= shellxquote=]]
    vim.opt.bomb = true
	if work_config.enabled then
		vim.opt.rtp:append(vim.fn.stdpath "config" .. "C:/Users/ccummings/AppData/Local/nvim/runtime")
		vim.env.TEMP = "C:\\Users\\ccummings\\AppData\\Local\\Temp"
		vim.env.RBTOOLS_CONFIG_PATH = "C:\\Users\\ccummings"
	    vim.api.nvim_set_current_dir("C:\\projects\\")
		--DIY powershell profile
		 vim.api.nvim_create_autocmd('TermOpen', {
		      callback = function()
                  local txt = vim.fs.dirname(vim.env.MYVIMRC) .. "/powershell_profile.ps1"
                  local file, err = io.open(txt, "rb")
                  if file then
                      local ps_profile = file:read("*a")
                      vim.api.nvim_chan_send(vim.bo.channel, ps_profile)
                      vim.api.nvim_chan_send(vim.bo.channel, "clear\r")
                      file:close()
                  end
              end, --autocmd callback function
	     })
    end
end

  -- Set up cmp with lsp
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
