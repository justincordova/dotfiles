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
  keys = {
    { 'zR', function() require('ufo').openAllFolds() end, desc = 'Open all folds' },
    { 'zM', function() require('ufo').closeAllFolds() end, desc = 'Close all folds' },
    { 'zr', function() require('ufo').openFoldsExceptKinds() end, desc = 'Fold less' },
    { 'zm', function() require('ufo').closeFoldsWith() end, desc = 'Fold more' },
    {
      'zp',
      function()
        local winid = require('ufo').peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end,
      desc = 'Peek fold',
    },
    -- Leader z mirrors for which-key discoverability
    { '<leader>za', 'za', desc = 'Toggle fold', remap = true },
    { '<leader>zo', 'zo', desc = 'Open fold', remap = true },
    { '<leader>zc', 'zc', desc = 'Close fold', remap = true },
    { '<leader>zO', 'zO', desc = 'Open fold recursively', remap = true },
    { '<leader>zC', 'zC', desc = 'Close fold recursively', remap = true },
    { '<leader>zR', function() require('ufo').openAllFolds() end, desc = 'Open all folds' },
    { '<leader>zM', function() require('ufo').closeAllFolds() end, desc = 'Close all folds' },
    { '<leader>zr', function() require('ufo').openFoldsExceptKinds() end, desc = 'Fold less' },
    { '<leader>zm', function() require('ufo').closeFoldsWith() end, desc = 'Fold more' },
    {
      '<leader>zp',
      function()
        local winid = require('ufo').peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end,
      desc = 'Peek fold',
    },
  },
}
