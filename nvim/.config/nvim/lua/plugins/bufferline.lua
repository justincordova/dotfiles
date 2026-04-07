return {
  'romgrk/barbar.nvim',
  dependencies = {
    'lewis6991/gitsigns.nvim',
    { 'nvim-tree/nvim-web-devicons', optional = true },
  },
  init = function() vim.g.barbar_auto_setup = false end,
  event = 'VeryLazy',
  opts = {
    animation = true,
    clickable = true,
    auto_hide = false,
    tabpages = true,
    icons = {
      filetype = {
        enabled = true,
      },
      buffer_index = false,
      buffer_number = false,
      button = '',
      modified = {button = '●'},
      pinned = {button = '', filename = true},
      separator = {left = '▎', right = ''},
      separator_at_end = true,
      diagnostics = {
        [vim.diagnostic.severity.ERROR] = {enabled = false},
        [vim.diagnostic.severity.WARN] = {enabled = false},
        [vim.diagnostic.severity.INFO] = {enabled = false},
        [vim.diagnostic.severity.HINT] = {enabled = false},
      },
      gitsigns = {
        added = {enabled = true, icon = '+'},
        changed = {enabled = true, icon = '~'},
        deleted = {enabled = true, icon = '-'},
      },
    },
    sidebar_filetypes = {
      ['neo-tree'] = {event = 'BufWipeout', text = 'File Explorer', align = 'left'},
      undotree = {text = 'undotree', align = 'right'},
    },
    maximum_length = 30,
    maximum_padding = 1,
    minimum_padding = 1,
  },
  version = '^1.0.0',
  config = function(_, opts)
    require('barbar').setup(opts)

    vim.api.nvim_create_user_command('BufferCloseAll', function()
      local buffers = vim.api.nvim_list_bufs()
      for i = #buffers, 1, -1 do
        local buf = buffers[i]
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
          pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
      end
      local has_neo_tree = false
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        if name:match("neo%-tree") then
          has_neo_tree = true
          break
        end
      end
      if not has_neo_tree then
        vim.cmd('enew')
      end
    end, { desc = 'Close all buffers' })

    vim.api.nvim_create_autocmd('BufWinEnter', {
      pattern = 'neo-tree*',
      callback = function()
        vim.cmd('redrawtabline')
      end,
    })
  end
}
