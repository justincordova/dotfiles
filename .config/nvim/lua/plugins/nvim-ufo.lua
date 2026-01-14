-- [[ Better Folding ]]
return {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },
  event = 'VeryLazy',
  opts = {
    provider_selector = function()
      return { 'treesitter', 'indent' }
    end,
  },
  init = function()
    -- Fold keymaps (both z and <leader>z for convenience)
    vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
    vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds, { desc = 'Fold less' })
    vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith, { desc = 'Fold more' })
    vim.keymap.set('n', 'zp', function()
      local winid = require('ufo').peekFoldedLinesUnderCursor()
      if not winid then
        vim.lsp.buf.hover()
      end
    end, { desc = 'Peek fold' })

    -- Leader z mappings for easy access (same commands as z but with leader)
    vim.keymap.set('n', '<leader>za', 'za', { desc = 'Toggle fold', remap = true })
    vim.keymap.set('n', '<leader>zo', 'zo', { desc = 'Open fold', remap = true })
    vim.keymap.set('n', '<leader>zc', 'zc', { desc = 'Close fold', remap = true })
    vim.keymap.set('n', '<leader>zO', 'zO', { desc = 'Open fold recursively', remap = true })
    vim.keymap.set('n', '<leader>zC', 'zC', { desc = 'Close fold recursively', remap = true })
    vim.keymap.set('n', '<leader>zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
    vim.keymap.set('n', '<leader>zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
    vim.keymap.set('n', '<leader>zr', require('ufo').openFoldsExceptKinds, { desc = 'Fold less' })
    vim.keymap.set('n', '<leader>zm', require('ufo').closeFoldsWith, { desc = 'Fold more' })
    vim.keymap.set('n', '<leader>zp', function()
      local winid = require('ufo').peekFoldedLinesUnderCursor()
      if not winid then
        vim.lsp.buf.hover()
      end
    end, { desc = 'Peek fold' })
  end,
}
