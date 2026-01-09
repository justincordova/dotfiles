-- Keymaps are automatically loaded on the VeryLazy event
-- Add any additional keymaps here

-- Keybind to switch colorschemes
vim.keymap.set("n", "<leader>cs", function()
  Snacks.picker.colorschemes()
end, { desc = "Colorscheme Switcher" })

-- Disable terminal keymaps to favor tmux
vim.keymap.del("n", "<leader>ft")
vim.keymap.del("n", "<leader>fT")
vim.keymap.del("n", "<c-/>")
vim.keymap.del("n", "<c-_>")

-- Edit pinned directories
vim.keymap.set("n", "<leader>ep", function()
  vim.cmd("edit " .. vim.fn.stdpath("config") .. "/lua/config/pins.lua")
end, { desc = "Edit pinned directories" })

-- Reload pins + redraw dashboard
vim.keymap.set("n", "<leader>rp", function()
  package.loaded["config.pins"] = nil
  -- Reopen dashboard with Snacks
  vim.cmd("enew")
  Snacks.dashboard.open()
end, { desc = "Reload pinned directories" })