-- [[ Diff View ]]
return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Diff view' },
    { '<leader>gf', '<cmd>DiffviewFileHistory %<cr>', desc = 'File history' },
    { '<leader>gl', '<cmd>DiffviewFileHistory<cr>', desc = 'Project history (log)' },
  },
}
