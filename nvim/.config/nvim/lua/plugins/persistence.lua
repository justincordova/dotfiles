-- [[ Session Management ]]
return {
  'folke/persistence.nvim',
  event = 'BufReadPre',
  opts = {
    options = { 'buffers', 'curdir', 'tabpages', 'winsize' },
    pre_save = function()
      vim.cmd [[Neotree close]]
    end,
  },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'PersistenceLoadPost',
      callback = function()
        vim.cmd [[Neotree close]]
        vim.cmd [[Neotree show]]
      end,
    })
  end,
  keys = {
    {
      '<leader>qs',
      function()
        require('persistence').load()
      end,
      desc = 'Restore Session',
    },
    {
      '<leader>qS',
      function()
        require('persistence').select()
      end,
      desc = 'Select Session',
    },
    {
      '<leader>ql',
      function()
        require('persistence').load { last = true }
      end,
      desc = 'Restore Last Session',
    },
    {
      '<leader>qd',
      function()
        require('persistence').stop()
      end,
      desc = "Don't Save Current Session",
    },
    {
      '<leader>qq',
      '<cmd>qa<cr>',
      desc = 'Quit All',
    },
  },
}
