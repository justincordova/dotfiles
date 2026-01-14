-- [[ Cursor Animation ]]
return {
  'sphamba/smear-cursor.nvim',
  event = 'VeryLazy',
  opts = {
    cursor_color = '#d3cdc3',
    normal_bg = '#282828',
    smear_between_buffers = true,
    smear_between_neighbor_lines = true,
    legacy_computing_symbols_support = false,
  },
}
