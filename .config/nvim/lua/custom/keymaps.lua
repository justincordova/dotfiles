-- [[ Basic Keymaps ]]
-- See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc><Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Diagnostic keymaps (navigate only - trouble handles viewing)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })

-- Exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Save file
vim.keymap.set("n", "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
vim.keymap.set("i", "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
vim.keymap.set("v", "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Better indenting
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- Clipboard (macOS Cmd keys)
vim.keymap.set({ "n", "v" }, "<D-v>", '"+p', { desc = "Paste from clipboard" })
vim.keymap.set({ "i", "c" }, "<D-v>", '<C-r>+', { desc = "Paste from clipboard" })
vim.keymap.set("v", "<D-c>", '"+y', { desc = "Copy to clipboard" })

-- Move lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Buffer navigation
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
-- Note: [b and ]b are defined in barbar.lua

-- Window navigation (will be enhanced by tmux-navigator)
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Buffer Management (Leader b)
vim.keymap.set("n", "<leader>bn", "<cmd>enew<cr>", { desc = "New buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>BufferClose<cr>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bD", "<cmd>BufferClose<cr>", { desc = "Delete buffer (force)" })
vim.keymap.set("n", "<leader>bo", "<cmd>BufferCloseAllButCurrent<CR>", { desc = "Delete other buffers" })
vim.keymap.set("n", "<leader>bp", "<cmd>BufferPick<CR>", { desc = "Pick buffer" })
vim.keymap.set("n", "<leader>bP", "<cmd>BufferPin<CR>", { desc = "Pin buffer" })

-- Barbar keybindings (Alt key)
vim.keymap.set('n', '<A-,>', '<Cmd>BufferPrevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<A-.>', '<Cmd>BufferNext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', { desc = 'Move buffer left' })
vim.keymap.set('n', '<A->>', '<Cmd>BufferMoveNext<CR>', { desc = 'Move buffer right' })
vim.keymap.set('n', '<A-1>', '<Cmd>BufferGoto 1<CR>', { desc = 'Goto buffer 1' })
vim.keymap.set('n', '<A-2>', '<Cmd>BufferGoto 2<CR>', { desc = 'Goto buffer 2' })
vim.keymap.set('n', '<A-3>', '<Cmd>BufferGoto 3<CR>', { desc = 'Goto buffer 3' })
vim.keymap.set('n', '<A-4>', '<Cmd>BufferGoto 4<CR>', { desc = 'Goto buffer 4' })
vim.keymap.set('n', '<A-5>', '<Cmd>BufferGoto 5<CR>', { desc = 'Goto buffer 5' })
vim.keymap.set('n', '<A-6>', '<Cmd>BufferGoto 6<CR>', { desc = 'Goto buffer 6' })
vim.keymap.set('n', '<A-7>', '<Cmd>BufferGoto 7<CR>', { desc = 'Goto buffer 7' })
vim.keymap.set('n', '<A-8>', '<Cmd>BufferGoto 8<CR>', { desc = 'Goto buffer 8' })
vim.keymap.set('n', '<A-9>', '<Cmd>BufferGoto 9<CR>', { desc = 'Goto buffer 9' })
vim.keymap.set('n', '<A-0>', '<Cmd>BufferLast<CR>', { desc = 'Goto last buffer' })
vim.keymap.set('n', '<A-p>', '<Cmd>BufferPin<CR>', { desc = 'Pin buffer' })
vim.keymap.set('n', '<A-c>', '<Cmd>BufferClose<CR>', { desc = 'Close buffer' })
vim.keymap.set('n', '<C-p>', '<Cmd>BufferPick<CR>', { desc = 'Pick buffer' })
vim.keymap.set('n', '<C-s-p>', '<Cmd>BufferPickDelete<CR>', { desc = 'Pick & delete buffer' })
vim.keymap.set('n', '<leader>b1', '<Cmd>BufferGoto 1<CR>', { desc = 'Goto buffer 1' })
vim.keymap.set('n', '<leader>b2', '<Cmd>BufferGoto 2<CR>', { desc = 'Goto buffer 2' })
vim.keymap.set('n', '<leader>b3', '<Cmd>BufferGoto 3<CR>', { desc = 'Goto buffer 3' })
vim.keymap.set('n', '<leader>b4', '<Cmd>BufferGoto 4<CR>', { desc = 'Goto buffer 4' })
vim.keymap.set('n', '<leader>b5', '<Cmd>BufferGoto 5<CR>', { desc = 'Goto buffer 5' })
vim.keymap.set('n', '<leader>b6', '<Cmd>BufferGoto 6<CR>', { desc = 'Goto buffer 6' })
vim.keymap.set('n', '<leader>b7', '<Cmd>BufferGoto 7<CR>', { desc = 'Goto buffer 7' })
vim.keymap.set('n', '<leader>b8', '<Cmd>BufferGoto 8<CR>', { desc = 'Goto buffer 8' })
vim.keymap.set('n', '<leader>b9', '<Cmd>BufferGoto 9<CR>', { desc = 'Goto buffer 9' })
vim.keymap.set('n', '<leader>b0', '<Cmd>BufferLast<CR>', { desc = 'Goto last buffer' })
vim.keymap.set('n', '<leader>ba', '<Cmd>BufferCloseAllButCurrent<CR>', { desc = 'Close all but current' })
vim.keymap.set('n', '<leader>bb', '<Cmd>BufferOrderByBufferNumber<CR>', { desc = 'Sort by buffer number' })
vim.keymap.set('n', '<leader>bd', '<Cmd>BufferOrderByDirectory<CR>', { desc = 'Sort by directory' })
vim.keymap.set('n', '<leader>bl', '<Cmd>BufferOrderByLanguage<CR>', { desc = 'Sort by language' })
vim.keymap.set('n', '<leader>bN', '<Cmd>BufferOrderByName<CR>', { desc = 'Sort by name' })
vim.keymap.set('n', '<leader>bw', '<Cmd>BufferOrderByWindowNumber<CR>', { desc = 'Sort by window number' })
vim.keymap.set('n', '<leader>bC', '<Cmd>BufferRestore<CR>', { desc = 'Restore buffer' })
vim.keymap.set('n', '<leader>bc', '<Cmd>BufferClose<CR>', { desc = 'Close buffer' })

-- Window Management (Leader w)
vim.keymap.set("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split vertical" })
vim.keymap.set("n", "<leader>ws", "<cmd>split<cr>", { desc = "Split horizontal" })
vim.keymap.set("n", "<leader>wc", "<cmd>close<cr>", { desc = "Close window" })
vim.keymap.set("n", "<leader>wo", "<cmd>only<cr>", { desc = "Close other windows" })
vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Equal window size" })
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Go to right window" })

-- UI Toggles (Leader u)
vim.keymap.set("n", "<leader>un", "<cmd>set number!<cr>", { desc = "Toggle line numbers" })
vim.keymap.set("n", "<leader>ur", "<cmd>set relativenumber!<cr>", { desc = "Toggle relative numbers" })
vim.keymap.set("n", "<leader>uw", "<cmd>set wrap!<cr>", { desc = "Toggle word wrap" })
vim.keymap.set("n", "<leader>us", "<cmd>set spell!<cr>", { desc = "Toggle spell check" })

-- Quick Actions
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
vim.keymap.set("n", "<leader>cs", function()
  vim.g.auto_save_enabled = not vim.g.auto_save_enabled
  if vim.g.auto_save_enabled then
    vim.notify("Auto-save enabled", vim.log.levels.INFO, { title = "Auto-save" })
  else
    vim.notify("Auto-save disabled", vim.log.levels.WARN, { title = "Auto-save" })
  end
end, { desc = "Toggle auto-save" })
vim.keymap.set("n", "<leader>h", function()
  -- Find existing checkhealth buffer
  local health_buf = nil
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname:match("checkhealth") or vim.bo[bufnr].filetype == "checkhealth" then
      health_buf = bufnr
      break
    end
  end

  -- If buffer exists, show it in current window (reuse buffer)
  if health_buf and vim.api.nvim_buf_is_loaded(health_buf) then
    vim.api.nvim_set_current_buf(health_buf)
    return
  end

  -- Create new checkhealth buffer
  -- Save current window to return to it
  local current_win = vim.api.nvim_get_current_win()

  -- Run checkhealth (opens in new tab)
  vim.cmd("checkhealth")

  -- Get the checkhealth buffer that was just created
  health_buf = vim.api.nvim_get_current_buf()

  -- Close the tab that checkhealth created
  vim.cmd("tabclose")

  -- Go back to original window and show checkhealth buffer there
  vim.api.nvim_set_current_win(current_win)
  vim.api.nvim_set_current_buf(health_buf)

  -- Configure buffer options
  vim.bo[health_buf].buflisted = false
  vim.bo[health_buf].bufhidden = "wipe"
end, { desc = "Check Health" })
vim.keymap.set("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason" })
vim.keymap.set("n", "<leader>gg", ":!tmux new-window -c " .. vim.fn.getcwd() .. " -- lazygit <CR><CR>", { silent = true, desc = "LazyGit" })
vim.keymap.set("n", "<leader>,", "<cmd>Telescope buffers<cr>", { desc = "Switch Buffer" })
vim.keymap.set("n", "<leader>-", "<cmd>split<cr>", { desc = "Split Below" })
vim.keymap.set("n", "<leader>\\", "<cmd>vsplit<cr>", { desc = "Split Right" })
vim.keymap.set("n", "<leader>:", "<cmd>Telescope command_history<cr>", { desc = "Command History" })

-- Scratch
local scratch = require "custom.scratch"
scratch.setup()
vim.keymap.set("n", "<leader>so", scratch.open, { desc = "Open scratch" })
vim.keymap.set("n", "<leader>se", scratch.export, { desc = "Export scratch" })
vim.keymap.set("n", "<leader>ss", scratch.search_fleeting, { desc = "Search fleeting notes" })
-- Note: Plugin-specific keymaps will be defined in their respective plugin config files
-- This includes: telescope, neo-tree, gitsigns, LSP, trouble, undotree, etc.
