-- ========================================================================== --
-- ==                           NEOVIDE SETTINGS 													 == --
-- ========================================================================== --
if vim.g.neovide then
	vim.g.neovide_cursor_animation_length = 0
	vim.g.neovide_cursor_vfx_mode = ""
end

-- ========================================================================== --kk
-- ==                           EDITOR SETTINGS                            == --
-- ========================================================================== --
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

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
vim.keymap.set({ 'n', 'x', 'o' }, '<c-c>', '"+y') -- copy
vim.keymap.set({ 'n', 'x', 'o' }, '<c-v>', '"+p') -- paste

-- Jump to Warnings/Errors
vim.keymap.set('n', '[d', function() vim.diagnostic.goto_prev() end)
vim.keymap.set('n', ']d', function() vim.diagnostic.goto_next() end)

-- Formatting
vim.keymap.set('n', '<space>f', function()
	vim.lsp.buf.format { async = true }
end)

-- Map ESC/Ctrl-[
vim.keymap.set('i', 'jj', '<Esc>')

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
	{ 'catppuccin/nvim',                          name = 'catppuccin', priority = 1000 },
	{ 'nvim-lualine/lualine.nvim' },
	{ 'nvim-lua/plenary.nvim' },
	{ 'nvim-tree/nvim-tree.lua' },
	{ 'nvim-treesitter/nvim-treesitter' },
	{ 'nvim-telescope/telescope.nvim',            branch = '0.1.x' },
	{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
	{ 'echasnovski/mini.comment',                 branch = 'stable' },
	{ 'echasnovski/mini.surround',                branch = 'stable' },
	{ 'VonHeikemen/lsp-zero.nvim',                branch = 'v3.x' },
	{ 'lewis6991/gitsigns.nvim' },
	{ 'neovim/nvim-lspconfig' },
	{ 'hrsh7th/nvim-cmp' },
	{ 'hrsh7th/cmp-nvim-lsp' },
	{ 'hrsh7th/cmp-buffer' },
	{ 'L3MON4D3/LuaSnip' },
	{ 'numToStr/FTerm.nvim' },
})


-- ========================================================================== --
-- ==                         PLUGIN CONFIGURATION                         == --
-- ========================================================================== --

-- Colorscheme settings
vim.cmd.colorscheme('catppuccin-frappe')

-- File Tree
require('nvim-tree').setup()
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle %:p:h<cr>')

-- See :help lualine.txt
require('lualine').setup({
	options = {
		theme = 'catppuccin-frappe',
		icons_enabled = false,
		component_separators = '|',
		section_separators = '',
	},
	sections = {
		lualine_z = {
			{
				function()
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if vim.api.nvim_buf_get_option(buf, 'modified') then
							return 'UNSAVED'
						end
					end
					return ''
				end,
			},
		},
	},
})

-- See :help nvim-treesitter-modules
require('nvim-treesitter.configs').setup({
	highlight = {
		enable = true,
	},
	ensure_installed = { 'lua', 'vim', 'vimdoc', 'json', 'python' },
	sync_install = true,
	auto_install = true,
	ignore_install = {},
	modules = {},
})

-- See "help MiniComment.config
require('mini.comment').setup({})
vim.keymap.set('n', '<C-/>', 'gcc', { remap = true })

-- See "help MiniSurround.config
require('mini.surround').setup({})

-- See :help telescope.builtin
vim.keymap.set('n', '<leader>?', '<cmd>Telescope oldfiles<cr>')
vim.keymap.set('n', '<leader><space>', '<cmd>Telescope buffers<cr>')
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>')
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')
vim.keymap.set('n', '<leader>fd', '<cmd>Telescope diagnostics<cr>')
vim.keymap.set('n', '<leader>fs', '<cmd>telescope current_buffer_fuzzy_find<cr>')

require('telescope').load_extension('fzf')

-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/lsp.md#how-does-it-work
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(_, bufnr)
	-- See :help lsp-zero-keybindings
	lsp_zero.default_keymaps({ buffer = bufnr })
end)

-- See :help lspconfig-setup
-- require('lspconfig').tsserver.setup({})
-- require('lspconfig').eslint.setup({})
-- require('lspconfig').rust_analyzer.setup({})

local lsp_config = require('lspconfig')
lsp_config.pyright.setup({})
lsp_config.lua_ls.setup {
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
lsp_config.gdscript.setup({})

local cmp = require('cmp')

-- See :help cmp-config
cmp.setup({
	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'buffer' },
		{ name = 'luasnip' },
	},
	formatting = lsp_zero.cmp_format(),
})

require('gitsigns').setup()


-- FTerm Force Close and Toggle
vim.api.nvim_create_user_command('FTermExit', require('FTerm').exit, { bang = true })
vim.api.nvim_create_user_command('FTermToggle', require('FTerm').toggle, { bang = true })
vim.keymap.set({ 'n', 't' }, '<C-i>', '<cmd>FTermToggle<cr>')
vim.keymap.set('t', '<C-i>', '<cmd>FTermToggle<cr>')
vim.keymap.set('t', '<C-n>', '<cmd>FTermExit<cr>')
