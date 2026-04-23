-- [[ Neo-tree File Explorer ]]
return {
  "nvim-neo-tree/neo-tree.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-tree/nvim-web-devicons", optional = true },
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  init = function()
    -- If we open a directory (e.g. nvim .), load neo-tree immediately
    if vim.fn.argc() == 1 then
      local stat = vim.uv.fs_stat(vim.fn.argv(0))
      if stat and stat.type == "directory" then
        require("neo-tree")
      end
    end
  end,
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer (root dir)" },
    { "<leader>E", "<cmd>Neotree toggle dir=%:p:h<cr>", desc = "Explorer (cwd)" },
    { "<leader>ge", "<cmd>Neotree git_status<cr>", desc = "Git Explorer" },
    { "<leader>be", "<cmd>Neotree buffers<cr>", desc = "Buffer Explorer" },
  },
  deactivate = function()
    vim.cmd([[Neotree close]])
  end,
  config = function(_, opts)
    require("neo-tree").setup(opts)
    local refresh_neo_tree = function()
      local neo_tree = require("neo-tree")
      if neo_tree and neo_tree.command then
        pcall(function()
          neo_tree.command.execute({ action = "refresh", source = "git_status" })
          neo_tree.command.execute({ action = "refresh", source = "filesystem" })
        end)
      end
    end
    vim.api.nvim_create_autocmd('FocusGained', {
      callback = refresh_neo_tree,
    })
  end,
  opts = {
    sources = { "filesystem", "buffers", "git_status" },
    open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
    filesystem = {
      bind_to_cwd = false,
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
      hijack_netrw_behavior = "open_default",
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = {
          ".git",
          "node_modules",
        },
        never_show = {
          ".DS_Store",
          "thumbs.db",
        },
      },
    },
    window = {
      position = "left",
      width = 40,
      mappings = {
        ["l"] = "open",
        ["h"] = "close_node",
        ["<space>"] = "none",
        ["q"] = "close_window",
        ["<C-q>"] = function() vim.cmd("xa") end,
        ["Y"] = {
          function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            vim.fn.setreg("+", path, "c")
          end,
          desc = "Copy Path to Clipboard",
        },
        ["O"] = {
          function(state)
            require("lazy.util").open(state.tree:get_node().path, { system = true })
          end,
          desc = "Open with System Application",
        },
        ["P"] = { "toggle_preview", config = { use_float = false } },
      },
    },
    default_component_configs = {
      indent = {
        with_expanders = true,
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
      git_status = {
        symbols = {
          unstaged = "󰄱",
          staged = "󰱒",
        },
      },
    },
  },
}
