return {
  "epwalsh/obsidian.nvim",
  version = "*", 
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Obsidian Note" },
    { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search Obsidian" },
    { "<leader>ot", "<cmd>ObsidianTemplate<cr>", desc = "Insert Template" },
    { "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Obsidian Today" },
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/obsidian", -- Default path, adjust as needed
      },
    },
  },
}
