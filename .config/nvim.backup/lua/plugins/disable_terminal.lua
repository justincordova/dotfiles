return {
  -- Disable terminal features in Snacks if they are enabled by default
  {
    "folke/snacks.nvim",
    opts = {
      terminal = { enabled = false },
    },
  },
  -- Disable other common terminal plugins
  { "akinsho/toggleterm.nvim", enabled = false },
}
