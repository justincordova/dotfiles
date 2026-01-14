-- [[ Zen Mode - Distraction-Free Writing ]]
-- Focus mode for writing and reading
return {
  'folke/zen-mode.nvim',
  cmd = 'ZenMode',
  opts = {
    -- Window configuration
    window = {
      backdrop = 0.95, -- Shade the backdrop of the Zen window
      width = 0.85, -- Width of the Zen window (0-1 = percentage, >1 = columns)
      height = 1, -- Height of the Zen window
      options = {
        signcolumn = 'no', -- Disable signcolumn
        number = false, -- Disable number column
        relativenumber = false, -- Disable relative numbers
        cursorline = false, -- Disable cursorline
        cursorcolumn = false, -- Disable cursor column
        foldcolumn = '0', -- Disable fold column
        list = false, -- Disable whitespace characters
      },
    },
    -- Plugins to disable/enable
    plugins = {
      options = {
        enabled = true,
        ruler = false, -- Disables the ruler text in the cmd line area
        showcmd = false, -- Disables the command in the last line of the screen
        laststatus = 0, -- Turn off the statusline in zen mode
      },
      twilight = { enabled = false }, -- Enable twilight (ataraxis)
      gitsigns = { enabled = false }, -- Disables git signs
      tmux = { enabled = false }, -- Disables the tmux statusline
      kitty = {
        enabled = false,
        font = '+4', -- Font size increment
      },
      alacritty = {
        enabled = false,
        font = '14', -- Font size
      },
      wezterm = {
        enabled = false,
        font = '+4', -- Font size increment
      },
    },
    -- Callback where you can add custom code when the Zen window opens
    on_open = function(win) end,
    -- Callback where you can add custom code when the Zen window closes
    on_close = function() end,
  },
  keys = {
    {
      '<leader>z',
      '<cmd>ZenMode<cr>',
      desc = 'Zen Mode',
    },
  },
}
