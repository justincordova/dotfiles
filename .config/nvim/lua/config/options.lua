-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable perl and ruby providers to silence checkhealth warnings
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Set python3 host to avoid pyenv warning and ensure correct python is used
vim.g.python3_host_prog = "/opt/homebrew/bin/python3"

