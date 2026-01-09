return {
  -- GitHub Theme
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false,
    priority = 1000,
    config = function()
      require("github-theme").setup({
        -- options
      })
      vim.cmd.colorscheme("github_dark_default")
      -- Set dashboard header to red from GitHub Dark Default
      vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = "#ff7b72", bold = true })
    end,
  },

  -- Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      transparent_background = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,
        dashboard = true,
        mini = { enabled = true },
      },
    },
  },

  -- Tokyonight
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon" },
  },

  -- Kanagawa
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
  },

  -- Gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    lazy = true,
  },

  -- Evergarden
  {
    "comfysage/evergarden",
    priority = 1000,
    opts = {
      transparent_background = true,
      variant = "medium",
    },
  },
}
