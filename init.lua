-- Leader key
vim.g.mapleader = " "

-- Basic options
local opt = vim.opt
opt.number = true
opt.relativenumber = false
opt.cursorline = false
opt.smartindent = true
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.splitright = true
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.termguicolors = true
opt.background = "dark"

-- Enable syntax highlighting
-- vim.cmd("syntax on")

-- Bootstrap Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
    -- Catppuccin theme
    {
        "catppuccin/nvim",
        name = "catppuccin",
        config = function()
            require("catppuccin").setup({
                flavour = "mocha",
                background = { light = "latte", dark = "mocha" },
                transparent_background = false,
                term_colors = true,
                dim_inactive = { enabled = false },
                integrations = {
                    treesitter = true,
                    cmp = true,
                    gitsigns = true,
                    nvimtree = true,
                    native_lsp = { enabled = true },
                },
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    },

    -- Telescope
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

    -- Treesitter
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

    -- Nvim-tree
    { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },

    -- Git integration
    { "lewis6991/gitsigns.nvim" },

    -- Autocompletion
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip"
        }
    },

    -- Commenting
    { "numToStr/Comment.nvim", config = true },

    -- Key hints
    { "folke/which-key.nvim", config = true },

    -- Indent guides
    { "lukas-reineke/indent-blankline.nvim" },
})

-- Treesitter configuration
require('nvim-treesitter.configs').setup {
    ensure_installed = {
        "c", "cpp", "lua", "python", "javascript", "typescript",
        "rust", "go", "zig", "bash", "html", "css", "json",
        "yaml", "toml", "markdown", "markdown_inline", "make",
        "dockerfile", "gitignore", "sql", "vim", "jsonc"
    },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
    },
}


-- Highlight groups with black background
local hl = vim.api.nvim_set_hl
hl(0, "Normal", { bg = "#000000" })
hl(0, "NonText", { bg = "#000000" })
hl(0, "LineNr", { bg = "#000000" })
hl(0, "SignColumn", { bg = "#000000" })
hl(0, "VertSplit", { bg = "#000000" })
hl(0, "EndOfBuffer", { bg = "#000000" })

-- Configure which-key
require("which-key").setup {}
