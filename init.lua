require("core")
require("config.lazy")

local Plug = vim.fn['plug#']

vim.call('plug#begin')

Plug 'tpope/vim-sensible'
Plug 'nvim-lua/plenary.nvim'
Plug 'jakemason/ouroboros'

vim.call('plug#end')
