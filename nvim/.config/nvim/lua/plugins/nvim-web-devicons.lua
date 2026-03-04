return {
  'nvim-tree/nvim-web-devicons',
  lazy = true,
  opts = {
    -- Globally enable different highlight colors per icon (default to true)
    -- if set to false all icons will have the default icon's color
    color_icons = true,
    -- Globally enable default icons (default to false)
    -- will get overriden by `get_icon` option
    default = true,
    -- globally enable the default theme (default to "vim")
    theme = "auto",
  }
}
