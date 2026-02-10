-- [[ Cursor Animation ]]
return {
  'sphamba/smear-cursor.nvim',
  event = 'VeryLazy',
  opts = {
    cursor_color = '#d3cdc3',
    normal_bg = '#282828',
    smear_between_buffers = true,
    smear_between_neighbor_lines = true,
    legacy_computing_symbols_support = false,
  },
  config = function(_, opts)
    require('smear_cursor').setup(opts)

    local smear = require('smear_cursor')
    local scroll_timer = nil
    local scroll_count = 0
    local SCROLL_THRESHOLD = 3

    vim.api.nvim_create_autocmd('WinScrolled', {
      callback = function()
        scroll_count = scroll_count + 1

        if not smear.enabled then
          return
        end

        if scroll_count >= SCROLL_THRESHOLD then
          smear.enabled = false
        end

        if scroll_timer then
          vim.loop.timer_stop(scroll_timer)
        end

        scroll_timer = vim.loop.new_timer()
        scroll_timer:start(100, 0, function()
          vim.schedule(function()
            scroll_count = 0
            if not smear.enabled then
              smear.enabled = true
            end
          end)
        end)
      end,
    })
  end,
}
