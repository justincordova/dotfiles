-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Keybind to switch colorschemes
vim.keymap.set("n", "<leader>cs", function()
  Snacks.picker.colorschemes()
end, { desc = "Colorscheme Switcher" })