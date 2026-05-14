-- [[ Inc-Rename - Live Rename Preview ]]
-- See LSP rename changes in real-time as you type
return {
  'smjonas/inc-rename.nvim',
  cmd = 'IncRename',
  opts = {
    cmd_name = 'IncRename',
    hl_group = 'Substitute',
    preview_empty_name = false,
    show_message = true,
    input_buffer_type = nil,
    post_hook = nil,
  },
}
