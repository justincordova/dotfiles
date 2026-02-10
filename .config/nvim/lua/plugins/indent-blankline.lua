-- [[ Indent Guides ]]
return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {
    indent = {
      char = '│',
      tab_char = '│',
    },
    scope = {
      enabled = false,
      show_start = false,
      show_end = false,
    },
    exclude = {
      filetypes = {
        'help',
        'dashboard',
        'neo-tree',
        'Trouble',
        'trouble',
        'lazy',
        'mason',
        'notify',
        'toggleterm',
        'lazyterm',
        'markdown',
      },
    },
  },
  config = function(_, opts)
    require('ibl').setup(opts)

    -- Toggle keybinding
    vim.keymap.set('n', '<leader>ui', '<cmd>IBLToggle<cr>', { desc = 'Toggle indent guides' })
  end,
}
