-- [[ Notifications ]]
return {
  'rcarriga/nvim-notify',
  keys = {
    {
      '<leader>un',
      function()
        require('notify').dismiss { silent = true, pending = true }
      end,
      desc = 'Dismiss all notifications',
    },
    {
      '<leader>.',
      function()
        local action_state = require('telescope.actions.state')

        require('telescope').extensions.notify.notify {
          attach_mappings = function(prompt_bufnr, map)
            -- Disable mouse clicks (they close the picker by default)
            map('i', '<LeftMouse>', function() end)
            map('n', '<LeftMouse>', function() end)
            map('i', '<2-LeftMouse>', function() end)
            map('n', '<2-LeftMouse>', function() end)
            map('i', '<RightMouse>', function() end)
            map('n', '<RightMouse>', function() end)

            -- Press 'y' to copy notification to clipboard
            map('n', 'y', function()
              local selection = action_state.get_selected_entry()
              if selection then
                vim.fn.setreg('+', selection.value.message)
                vim.notify('Copied to clipboard!', vim.log.levels.INFO, { timeout = 1000 })
              end
            end)

            -- Press Enter to open notification in a readable buffer
            map('i', '<CR>', function()
              local selection = action_state.get_selected_entry()
              if not selection then
                return
              end

              -- Create a scratch buffer with the notification
              local buf = vim.api.nvim_create_buf(false, true)
              vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
              vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
              vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')

              -- Split the message into lines
              local lines = vim.split(selection.value.message, '\n')
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

              -- Open in a split
              vim.cmd('split')
              vim.api.nvim_win_set_buf(0, buf)
              vim.api.nvim_win_set_height(0, math.min(#lines + 2, 15))

              -- Close with q
              vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, silent = true })
            end)

            map('n', '<CR>', function()
              local selection = action_state.get_selected_entry()
              if not selection then
                return
              end

              local buf = vim.api.nvim_create_buf(false, true)
              vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
              vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
              vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')

              local lines = vim.split(selection.value.message, '\n')
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

              vim.cmd('split')
              vim.api.nvim_win_set_buf(0, buf)
              vim.api.nvim_win_set_height(0, math.min(#lines + 2, 15))

              vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, silent = true })
            end)

            return true -- Keep default mappings except what we overrode
          end,
        }
      end,
      desc = 'Notification History',
    },
  },
  opts = {
    timeout = 3000,
    max_height = function()
      return math.floor(vim.o.lines * 0.75)
    end,
    max_width = function()
      return math.floor(vim.o.columns * 0.75)
    end,
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { zindex = 100 })
    end,
  },
  init = function()
    -- Set nvim-notify as the default notify handler
    vim.notify = require 'notify'
  end,
}
