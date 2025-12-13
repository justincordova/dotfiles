-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Toggle Neo-tree with <leader>e
vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })

-- Reveal current file with <leader>r
vim.keymap.set("n", "<leader>r", ":Neotree reveal<CR>", { desc = "Reveal current file" })

-- ToggleTerm
vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })

-- Trouble
vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<CR>", { desc = "Toggle Trouble" })
vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<CR>", { desc = "Workspace Diagnostics" })
vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<CR>", { desc = "Document Diagnostics" })
vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<CR>", { desc = "Location List" })
vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<CR>", { desc = "Quickfix List" })
vim.keymap.set(
    "n",
    "<leader>sx",
    require("telescope.builtin").resume,
    { noremap = true, silent = true, desc = "Resume" }
)

-- Toggle Autocompletion
vim.keymap.set("n", "<leader>cx", function()
  vim.g.cmp_disabled = not vim.g.cmp_disabled
  if vim.g.cmp_disabled then
    vim.notify("Autocompletion disabled", vim.log.levels.INFO, { title = "nvim-cmp" })
  else
    vim.notify("Autocompletion enabled", vim.log.levels.INFO, { title = "nvim-cmp" })
  end
end, { desc = "Toggle Autocompletion" })

-- Exit terminal mode with Esc
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Open vertical terminal split
vim.keymap.set("n", "<leader>tr", "<cmd>vsplit | term<cr>", { desc = "Vertical Terminal Split" })
