-- Bootstrap lazy.nvim if not installed
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

-- Setup plugins
require("lazy").setup({
  { "projekt0n/github-nvim-theme" }, -- GitHub theme
})

-- ==============================
--   UI & Colors
-- ==============================

vim.cmd("syntax on")
vim.opt.termguicolors = true
vim.opt.background = "dark"

-- Load GitHub theme (dark variant)
require("github-theme").setup({
  options = {
    theme_style = "dark", -- "dark", "dimmed", or "light"
  }
})
pcall(vim.cmd, "colorscheme github_dark")

-- Use terminal background instead of forcing black
vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
vim.cmd("hi NonText guibg=NONE ctermbg=NONE")
vim.cmd("hi LineNr guibg=NONE ctermbg=NONE")
vim.cmd("hi SignColumn guibg=NONE ctermbg=NONE")
vim.cmd("hi VertSplit guibg=NONE ctermbg=NONE")
vim.cmd("hi EndOfBuffer guibg=NONE ctermbg=NONE")

-- ==============================
--   Editor Settings
-- ==============================

-- Line numbers
vim.opt.number = true
vim.opt.cursorline = false

-- Indentation
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Behavior
vim.opt.wildmenu = true
vim.opt.undofile = true
vim.opt.splitright = true
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Scrolling & wrapping
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.wrap = false

-- ==============================
--   Keymaps
-- ==============================
vim.g.mapleader = " " -- Space as leader

local map = vim.keymap.set
map("n", "<leader>w", ":w<CR>") -- Save
map("n", "<leader>q", ":q<CR>") -- Quit
map("n", "<leader>h", ":nohlsearch<CR>") -- Clear search highlight

