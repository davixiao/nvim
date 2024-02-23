-- ========================================================================== --
-- ==                           NEOVIDE SETTINGS 													 == --
-- ========================================================================== --
if vim.g.neovide then
	vim.g.neovide_cursor_animation_length = 0
	vim.g.neovide_cursor_vfx_mode = ""
end

-- ========================================================================== --
-- ==                           EDITOR SETTINGS                            == --
-- ========================================================================== --
vim.opt.number = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 5

-- Space as leader key
vim.g.mapleader = ' '

-- Basic clipboard interaction
vim.keymap.set({'n', 'x', 'o'}, '<c-c>', '"+y') -- copy
vim.keymap.set({'n', 'x', 'o'}, '<c-v>', '"+p') -- paste

-- ========================================================================== --
-- ==                               PLUGINS                                == --
-- ========================================================================== --

local lazy = {}

function lazy.install(path)
  if not vim.loop.fs_stat(path) then
    print('Installing lazy.nvim....')
    vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable', -- latest stable release
      path,
    })
  end
end

function lazy.setup(plugins)
  if vim.g.plugins_ready then
    return
  end

  lazy.install(lazy.path)
  vim.opt.rtp:prepend(lazy.path)

  require('lazy').setup(plugins, lazy.opts)
  vim.g.plugins_ready = true
end

lazy.path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
lazy.opts = {}

lazy.setup({
  {'sainnhe/gruvbox-material'},
  {'nvim-lualine/lualine.nvim'},
  {'nvim-lua/plenary.nvim'},
  {'nvim-treesitter/nvim-treesitter'},
  {'nvim-telescope/telescope.nvim', branch = '0.1.x'},
  {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
  {'echasnovski/mini.comment', branch = 'stable'},
  {'echasnovski/mini.surround', branch = 'stable'},
  {'echasnovski/mini.bufremove', branch = 'stable'},
  {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
  {'neovim/nvim-lspconfig'},
  {'hrsh7th/nvim-cmp'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/cmp-buffer'},
  {'L3MON4D3/LuaSnip'},
})


-- ========================================================================== --
-- ==                         PLUGIN CONFIGURATION                         == --
-- ========================================================================== --

-- Colorscheme settings
vim.cmd('let g:gruvbox_material_better_performance = 1')
vim.cmd("let g:gruvbox_material_background = 'soft'")
vim.cmd.colorscheme('gruvbox-material')

vim.g.netrw_banner = 0
vim.g.netrw_winsize = 30

-- Toggle file explorer
-- See :help netrw-browse-maps
vim.keymap.set('n', '<leader>e', '<cmd>Lexplore<cr>')

-- Open file explorer in current folder
vim.keymap.set('n', '<leader>E', '<cmd>Lexplore %:p:h<cr>')

-- See :help lualine.txt
require('lualine').setup({
  options = {
    theme = 'gruvbox-material',
    icons_enabled = false,
    component_separators = '|',
    section_separators = '',
  },
})

-- See :help nvim-treesitter-modules
require('nvim-treesitter.configs').setup({
  highlight = {
    enable = true,
  },
  ensure_installed = {'lua', 'vim', 'vimdoc', 'json'},
})

-- See "help MiniComment.config
require('mini.comment').setup({})

-- See "help MiniSurround.config
require('mini.surround').setup({})

-- See :help telescope.builtin
vim.keymap.set('n', '<leader>?', '<cmd>Telescope oldfiles<cr>')
vim.keymap.set('n', '<leader><space>', '<cmd>Telescope buffers<cr>')
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>')
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')
vim.keymap.set('n', '<leader>fd', '<cmd>Telescope diagnostics<cr>')
vim.keymap.set('n', '<leader>fs', '<cmd>Telescope current_buffer_fuzzy_find<cr>')

require('telescope').load_extension('fzf')

-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/lsp.md#how-does-it-work
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(_, bufnr)
  -- See :help lsp-zero-keybindings
  lsp_zero.default_keymaps({buffer = bufnr})
end)

-- See :help lspconfig-setup
-- require('lspconfig').tsserver.setup({})
-- require('lspconfig').eslint.setup({})
-- require('lspconfig').rust_analyzer.setup({})

local lsp_config = require('lspconfig')
lsp_config.pyright.setup{}
lsp_config.lua_ls.setup{
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using
				-- (most likely LuaJIT in the case of Neovim)
				version = 'LuaJIT',
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = {
					'vim',
					'require'
				},
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
		},
	},
}

local cmp = require('cmp')
local cmp_action = lsp_zero.cmp_action()

-- See :help cmp-config
cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
    {name = 'buffer'},
  },
  formatting = lsp_zero.cmp_format(),
  mapping = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({select = false}),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  })
})

