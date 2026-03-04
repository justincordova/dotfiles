-- [[ Setting options ]]
-- See `:help vim.opt`

-- Disable netrw (recommended for neo-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Disable perl and ruby providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Set python3 host
vim.g.python3_host_prog = "/opt/homebrew/bin/python3"

-- Font
vim.opt.guifont = 'JetBrainsMono Nerd Font:h12'

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim
vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Enable autoread
vim.opt.autoread = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Reduce message output (hide swapfile warnings, etc.)
vim.opt.shortmess:append({ W = true })

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor
vim.opt.scrolloff = 10

-- Conceallevel for plugins that hide markup
vim.opt.conceallevel = 2

-- Tab settings
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Command line completion
vim.opt.wildmode = 'longest:full,full' -- Command-line completion mode
vim.opt.wildoptions = 'pum' -- Popup menu for command-line completion

-- Wrap settings (wrapping.nvim will toggle this for text files)
vim.opt.wrap = false
vim.opt.linebreak = true -- Break at word boundaries, not mid-word

-- Auto-save toggle (global state)
vim.g.auto_save_enabled = false

-- Folding (will be enhanced by nvim-ufo)
vim.opt.foldcolumn = '1'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
