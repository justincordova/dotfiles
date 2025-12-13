return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      local toggleterm = require("toggleterm")
      toggleterm.setup({
        direction = "horizontal", -- default terminal opens at bottom
        size = 15, -- height of terminal
        open_mapping = [[<leader>t]], -- toggle with Space + t
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
      })

      local Terminal = require("toggleterm.terminal").Terminal

      -- Floating terminal
      local float_term = Terminal:new({ direction = "float" })

      -- Keymap to toggle bottom terminal (uses default direction)
      vim.keymap.set("n", "<leader>t", ":ToggleTerm<CR>", { desc = "Toggle bottom terminal" })

      -- Keymap to toggle floating terminal
      vim.keymap.set("n", "<leader>f", function()
        float_term:toggle()
      end, { desc = "Toggle floating terminal" })
    end,
  },
}
