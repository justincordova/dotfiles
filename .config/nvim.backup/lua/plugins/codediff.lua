return {
  "esmuellert/codediff.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  cmd = { "CodeDiff" },
  keys = {
    { "<leader>dc", "<cmd>CodeDiff<cr>", desc = "Code Diff (Side-by-Side)" },
  },
  opts = {},
}
