return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      background = { light = "latte", dark = "mocha" },
      transparent_background = false,
      integrations = {
        treesitter = true,
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        native_lsp = { enabled = true },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)

      -- Force black background
      local groups = {
        "Normal",
        "NonText",
        "LineNr",
        "SignColumn",
        "VertSplit",
        "EndOfBuffer",
      }

      for _, group in ipairs(groups) do
        vim.api.nvim_set_hl(0, group, { bg = "#000000" })
      end
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
