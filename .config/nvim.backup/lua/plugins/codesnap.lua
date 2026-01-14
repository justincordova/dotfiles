return {
  "mistricky/codesnap.nvim",
  build = "make",
  keys = {
    { "<leader>cS", "<cmd>CodeSnap<cr>", mode = "x", desc = "CodeSnap (Copy)" },
    { "<leader>cSS", "<cmd>CodeSnapSave<cr>", mode = "x", desc = "CodeSnap (Save)" },
  },
  opts = {
    save_path = "~/Pictures",
    has_breadcrumbs = true,
    bg_theme = "bamboo",
  },
}
