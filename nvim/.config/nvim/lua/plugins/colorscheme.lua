-- [[ Colorschemes ]]
return {
  -- Jellybeans (default theme)
  {
    'wtfox/jellybeans.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'jellybeans'
    end,
  },

  -- Catppuccin
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = true,
    priority = 1000,
    opts = {
      flavour = 'mocha',
      transparent_background = false,
      integrations = {
        cmp = true,
        barbar = true,
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
    end,
  },

  -- GitHub Themes
  {
    'projekt0n/github-nvim-theme',
    lazy = true,
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

  -- Rosé Pine
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = false,
    priority = 999,
    opts = {
      variant = 'auto',
      dark_variant = 'main',
      dim_inactive_windows = false,
      extend_background_behind_borders = true,
      enable = {
        terminal = true,
        legacy_highlights = true,
        migrations = true,
      },
      styles = {
        bold = true,
        italic = true,
        transparency = false,
      },
      groups = {
        border = 'muted',
        link = 'iris',
        panel = 'surface',
        error = 'love',
        hint = 'iris',
        info = 'foam',
        note = 'pine',
        todo = 'rose',
        warn = 'gold',
        git_add = 'foam',
        git_change = 'rose',
        git_delete = 'love',
        git_dirty = 'rose',
        git_ignore = 'muted',
        git_merge = 'iris',
        git_rename = 'pine',
        git_stage = 'iris',
        git_text = 'rose',
        git_untracked = 'subtle',
      },
      highlight_groups = {},
    },
    config = function(_, opts)
      require('rose-pine').setup(opts)
    end,
  },

  -- Kanso
  {
    'webhooked/kanso.nvim',
    lazy = false,
    priority = 999,
    opts = {
      bold = true,
      italics = true,
      compile = false,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = {},
      typeStyle = {},
      transparent = false,
      dimInactive = false,
      terminalColors = true,
      background = {
        dark = 'ink',
        light = 'pearl',
      },
      foreground = 'default',
      minimal = false,
    },
    config = function(_, opts)
      require('kanso').setup(opts)
    end,
  },
}
