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
	{ 'cpea2506/one_monokai.nvim' },
	{ 'nvim-lualine/lualine.nvim' },
	{ 'nvim-lua/plenary.nvim' },
	{
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
			"nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
	},
	{ 'nvim-treesitter/nvim-treesitter' },
	{ 'nvim-telescope/telescope.nvim',            branch = '0.1.x' },
	{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
	{ 'echasnovski/mini.comment',                 branch = 'stable' },
	{ 'echasnovski/mini.pairs',                   branch = 'stable' },
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
vim.cmd.colorscheme('one_monokai')

-- File Tree
-- require('nvim-tree').setup()
require("neo-tree").setup({
	filesystem = {
		follow_current_file = true,
		filtered_items = {
			visible = true,
			show_hidden_count = true,
			hide_dotfiles = false,
			hide_gitignored = false,
		}
	}
})
vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<cr>')
vim.keymap.set('n', '<leader>x', '<cmd>Neotree focus<cr>')

-- See :help lualine.txt
require('lualine').setup({
	options = {
		theme = 'one_monokai',
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
-- See "help MiniPairs.config
require('mini.pairs').setup({})

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

-- Python
lsp_config.pyright.setup({})

-- Lua
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
-- GDScript
lsp_config.gdscript.setup({})

-- Golang
-- lsp_config.gopls.setup({})
local cmp = require('cmp')

-- See :help cmp-config
cmp.setup({
	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'buffer' },
		{ name = 'luasnip' },
	},
	formatting = lsp_zero.cmp_format(),
	mapping = {
  	['<TAB>'] = cmp.mapping.select_next_item(),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
	},
})
-- 
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.go",
--   callback = function()
--     local params = vim.lsp.util.make_range_params()
--     params.context = {only = {"source.organizeImports"}}
--     -- buf_request_sync defaults to a 1000ms timeout. Depending on your
--     -- machine and codebase, you may want longer. Add an additional
--     -- argument after params if you find that you have to write the file
--     -- twice for changes to be saved.
--     -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
--     local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
--     for cid, res in pairs(result or {}) do
--       for _, r in pairs(res.result or {}) do
--         if r.edit then
--           local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
--           vim.lsp.util.apply_workspace_edit(r.edit, enc)
--         end
--       end
--     end
--     vim.lsp.buf.format({async = false})
--   end
-- })

require('gitsigns').setup()

-- FTerm Force Close and Toggle
vim.api.nvim_create_user_command('FTermExit', require('FTerm').exit, { bang = true })
vim.api.nvim_create_user_command('FTermToggle', require('FTerm').toggle, { bang = true })
vim.keymap.set({ 'n', 't' }, '<C-i>', '<cmd>FTermToggle<cr>')
vim.keymap.set('t', '<C-i>', '<cmd>FTermToggle<cr>')
vim.keymap.set('t', '<C-n>', '<cmd>FTermExit<cr>')
