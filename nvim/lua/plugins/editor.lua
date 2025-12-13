return {
    -- Disable Snacks Explorer
    {
        "folke/snacks.nvim",
        opts = {
            explorer = { enabled = false },
        },
    },

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
            "MunifTanjim/nui.nvim",
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
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
      require("neo-tree").setup({
        open_on_setup = true, -- open Neo-tree on startup
        close_if_last_window = false, -- keep Neo-tree open even if other windows close
        popup_border_style = "rounded",
        enable_git_status = true,
        filesystem = {
          follow_current_file = true, -- highlight the current file
          hijack_netrw_behavior = "open_default", -- replace netrw
        },
        buffers = {
          follow_current_file = false,
          auto_open = false, -- do NOT open buffers (Explorer Snacks) on startup
        },
        source_selector = {
          winbar = false, -- hide the source selector tab
        },
      })
    end,
    },
    {
        "folke/trouble.nvim",
        opts = {}, -- for default options, refer to the configuration section for custom setup.
        cmd = "Trouble",
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>cs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>xL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        },
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup {}
        end,
    },
}
