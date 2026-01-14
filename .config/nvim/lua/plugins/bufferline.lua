return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-web-devicons',
  event = 'VeryLazy',
  opts = {
    options = {
      mode = "buffers",
      separator_style = "slope",
      indicator = {
        icon = '▎',
        style = 'icon',
      },
      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(count, level)
        local icon = level:match("error") and " " or " "
        return " " .. icon .. count
      end,
      close_command = "bdelete! %d",
      right_mouse_command = "bdelete! %d",
      show_close_icon = true,
      show_buffer_icons = true,
      show_tab_indicators = true,
      always_show_bufferline = true,
      offsets = {
        {
          filetype = "neo-tree",
          text = "File Explorer",
          text_align = "left",
          separator = true,
        }
      },
    }
  },
  config = function(_, opts)
    require("bufferline").setup(opts)

    -- Update existing [b/]b to use BufferLine's better cycling
    vim.keymap.set('n', '[b', '<cmd>BufferLineCyclePrev<CR>', { desc = 'Prev buffer' })
    vim.keymap.set('n', ']b', '<cmd>BufferLineCycleNext<CR>', { desc = 'Next buffer' })

    -- New BufferLine-specific bindings
    vim.keymap.set('n', '<leader>bp', '<cmd>BufferLinePick<CR>', { desc = 'Pick buffer' })
    vim.keymap.set('n', '<leader>bP', '<cmd>BufferLineTogglePin<CR>', { desc = 'Pin buffer' })
  end
}
