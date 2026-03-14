-- [[ Basic Autocommands ]]
-- See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Auto-save on timer (after idle) and focus lost
vim.api.nvim_create_autocmd({ 'FocusLost', 'CursorHold' }, {
  desc = 'Auto-save on focus lost or after idle',
  group = vim.api.nvim_create_augroup('auto-save', { clear = true }),
  callback = function()
    if vim.g.auto_save_enabled and vim.bo.modified and vim.bo.buftype == '' and vim.fn.expand('%') ~= '' then
      vim.cmd('silent! update')
    end
  end,
})

-- Set filetype for docker-compose files
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  desc = 'Detect docker-compose files',
  group = vim.api.nvim_create_augroup('docker-compose-filetype', { clear = true }),
  pattern = { 'docker-compose*.yml', 'docker-compose*.yaml', 'compose*.yml', 'compose*.yaml' },
  callback = function()
    vim.bo.filetype = 'yaml.docker-compose'
  end,
})