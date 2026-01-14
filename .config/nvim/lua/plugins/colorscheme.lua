-- [[ Colorschemes ]]
return {
  -- Catppuccin (default theme)
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    opts = {
      flavour = 'mocha', -- latte, frappe, macchiato, mocha
      transparent_background = false,
      integrations = {
        cmp = true,
        bufferline = true,
        gitsigns = true,
        nvimtree = false,
        neotree = true,
        treesitter = true,
        notify = true,
        mini = {
          enabled = true,
        },
        telescope = {
          enabled = true,
        },
        which_key = true,
        indent_blankline = {
          enabled = true,
          colored_indent_levels = false,
        },
      },
    },
    config = function(_, opts)
      require('catppuccin').setup(opts)

      -- Load saved colorscheme or default to catppuccin-mocha
      local utils = require('custom.utils')
      local saved_colorscheme = utils.load_saved_colorscheme()

      if saved_colorscheme and saved_colorscheme ~= '' then
        pcall(vim.cmd.colorscheme, saved_colorscheme)
      else
        vim.cmd.colorscheme 'catppuccin-mocha'
      end
    end,
  },

  -- GitHub Themes
  {
    'projekt0n/github-nvim-theme',
    lazy = false,
    priority = 999,
    config = function()
      require('github-theme').setup {
        options = {
          transparent = false,
          terminal_colors = true,
          dim_inactive = false,
          styles = {
            comments = 'italic',
            keywords = 'bold',
            types = 'italic,bold',
          },
        },
      }
    end,
  },
}
