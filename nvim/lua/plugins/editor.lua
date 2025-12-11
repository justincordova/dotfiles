return {
  -- 1) Harpoon
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- 2) UndoTree
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", ":UndotreeToggle<CR>", desc = "Toggle UndoTree" },
    },
  },

  -- 3) FZF-Lua (Telescope alternative)
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- 4) SearchBox
  {
    "VonHeikemen/searchbox.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim"
    },
  },

  -- 6) Surround
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },

  -- 7) Comment-Box
  {
    "LudoPinelli/comment-box.nvim",
  },

  -- Primeagen VimBeGood
  {
    "ThePrimeagen/vim-be-good",
  },

  -- Todo Comments
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- Neogit (Git UI)
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- Smear-cursor (cursor animation)
    {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {},
    },


  -- Smoothie (smooth scrolling)
  {
    "psliwka/vim-smoothie",
    event = "VeryLazy",
  },
}