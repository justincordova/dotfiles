return {
  "epwalsh/obsidian.nvim",
  version = "*", 
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Obsidian Note" },
    { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search Obsidian" },
    { "<leader>ot", "<cmd>ObsidianTemplate<cr>", desc = "Insert Template" },
    { "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Obsidian Today" },
  },
  opts = {
    picker = {
      name = "telescope.nvim",
    },
    mappings = {
      -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
    },
    ui = { enable = false },
    workspaces = {
      {
        name = "personal",
        path = "/Users/justincordova/Library/Mobile Documents/iCloud~md~obsidian/Documents",
      },
    },
  },
}
