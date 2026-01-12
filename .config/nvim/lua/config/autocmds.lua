-- Autocmds are automatically loaded on the VeryLazy event
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`

-- Auto-save on FocusLost or CursorHold
vim.api.nvim_create_autocmd({ "FocusLost", "CursorHold" }, {
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! update")
    end
  end,
})