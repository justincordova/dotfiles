-- [[ Lualine Statusline ]]
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = function()
    local colors = {
      purple = '#cba6f7', -- Mauve
      lavender = '#b4befe', -- Lavender
      pink = '#f5c2e7', -- Pink
      bg = '#1e1e2e', -- Base
      fg = '#cdd6f4', -- Text
      black = '#181825', -- Mantle
    }

    local my_lualine_theme = {
      normal = {
        a = { bg = colors.purple, fg = colors.black, gui = 'bold' },
        b = { bg = colors.black, fg = colors.fg },
        c = { bg = colors.black, fg = colors.fg },
      },
      insert = {
        a = { bg = colors.pink, fg = colors.black, gui = 'bold' },
        b = { bg = colors.black, fg = colors.fg },
        c = { bg = colors.black, fg = colors.fg },
      },
      visual = {
        a = { bg = colors.lavender, fg = colors.black, gui = 'bold' },
        b = { bg = colors.black, fg = colors.fg },
        c = { bg = colors.black, fg = colors.fg },
      },
      replace = {
        a = { bg = colors.pink, fg = colors.black, gui = 'bold' },
        b = { bg = colors.black, fg = colors.fg },
        c = { bg = colors.black, fg = colors.fg },
      },
      inactive = {
        a = { bg = colors.black, fg = colors.fg, gui = 'bold' },
        b = { bg = colors.black, fg = colors.fg },
        c = { bg = colors.black, fg = colors.fg },
      },
    }

    return {
      options = {
        icons_enabled = true,
        theme = my_lualine_theme,
        component_separators = { left = '|', right = '|' },
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { 'neo-tree', 'lazy', 'trouble' },
    }
  end,
}
