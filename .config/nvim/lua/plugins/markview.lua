return {
  "OXY2DEV/markview.nvim",
  ft = "markdown",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons"
  },
  keys = {
    { "<leader>tm", "<cmd>Markview<cr>", desc = "Toggle Markview" },
  },
  opts = {
    preview = {
      enable = true,
    }
  }
}
