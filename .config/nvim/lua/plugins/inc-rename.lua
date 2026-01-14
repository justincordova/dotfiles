-- [[ Inc-Rename - Live Rename Preview ]]
-- See LSP rename changes in real-time as you type
return {
  'smjonas/inc-rename.nvim',
  cmd = 'IncRename',
  config = function()
    require('inc_rename').setup {
      -- Command name
      cmd_name = 'IncRename',
      -- Highlight group for the current word
      hl_group = 'Substitute',
      -- Preview empty names
      preview_empty_name = false,
      -- Show message after rename
      show_message = true,
      -- Input buffer type
      input_buffer_type = nil,
      -- Post hook for additional actions after rename
      post_hook = nil,
    }
  end,
  keys = {
    {
      '<leader>rn',
      function()
        return ':IncRename ' .. vim.fn.expand '<cword>'
      end,
      expr = true,
      desc = 'Rename (incremental)',
    },
  },
}
