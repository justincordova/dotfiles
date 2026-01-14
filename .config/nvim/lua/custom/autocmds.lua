-- [[ Basic Autocommands ]]
-- See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Auto-save on timer (2 seconds after idle) and focus lost
vim.api.nvim_create_autocmd({ 'FocusLost', 'CursorHold' }, {
  desc = 'Auto-save on focus lost or after idle',
  group = vim.api.nvim_create_augroup('auto-save', { clear = true }),
  callback = function()
    if vim.g.auto_save_enabled and vim.bo.modified and vim.bo.buftype == '' and vim.fn.expand('%') ~= '' then
      vim.cmd('silent! update')
    end
  end,
})

-- Set updatetime for CursorHold (2000ms = 2 seconds)
vim.opt.updatetime = 2000
