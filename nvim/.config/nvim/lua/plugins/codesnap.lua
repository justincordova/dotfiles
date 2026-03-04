-- [[ Code Screenshots ]]
return {
  'mistricky/codesnap.nvim',
  build = 'make',
  cmd = { 'CodeSnap', 'CodeSnapSave' },
  opts = {
    save_path = '~/Pictures/snips',
    has_breadcrumbs = false,
    bg_theme = 'black',
    watermark = '',
    show_line_number = false,
  },
}
