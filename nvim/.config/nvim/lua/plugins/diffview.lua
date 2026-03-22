-- [[ Diff View ]]
return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Diff view' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File history' },
    { '<leader>gH', '<cmd>DiffviewFileHistory<cr>', desc = 'Project history' },
  },
}
