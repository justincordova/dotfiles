-- Set <space> as the leader key
-- Must happen before plugins are loaded
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- Load config modules
require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.lazy')
