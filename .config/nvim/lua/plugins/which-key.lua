-- [[ Which-Key Configuration ]]
-- Note: Healthcheck warnings about overlapping keymaps for gc/gcc, gb/gbc, ys/yss, yS/ySS
-- are INTENTIONAL and expected. These plugins use Vim's timeout mechanism for multi-key
-- sequences. These are informational warnings, not errors that need fixing.
return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  opts = {
    notify = false, -- Disable which-key notifications to reduce noise
    preset = 'helix',
    win = {
      border = 'single',
      wo = {
        winblend = 0,
      },
    },
    layout = {
      width = { min = 20 },
      spacing = 3,
    },
    icons = {
      mappings = vim.g.have_nerd_font,
      rules = {
        { pattern = "Explorer", icon = " ", color = "blue" },
        { pattern = "Lazy", icon = "💤 ", color = "orange" },
        { pattern = "Split", icon = " ", color = "purple" },
        { pattern = "Command History", icon = " ", color = "yellow" },
        { pattern = "Rename", icon = "󰑕 ", color = "cyan" },
      },
      keys = vim.g.have_nerd_font and {} or {
        Up = '<Up> ',
        Down = '<Down> ',
        Left = '<Left> ',
        Right = '<Right> ',
        C = '<C-…> ',
        M = '<M-…> ',
        D = '<D-…> ',
        S = '<S-…> ',
        CR = '<CR> ',
        Esc = '<Esc> ',
        ScrollWheelDown = '<ScrollWheelDown> ',
        ScrollWheelUp = '<ScrollWheelUp> ',
        NL = '<NL> ',
        BS = '<BS> ',
        Space = '<Space> ',
        Tab = '<Tab> ',
        F1 = '<F1>',
        F2 = '<F2>',
        F3 = '<F3>',
        F4 = '<F4>',
        F5 = '<F5>',
        F6 = '<F6>',
        F7 = '<F7>',
        F8 = '<F8>',
        F9 = '<F9>',
        F10 = '<F10>',
        F11 = '<F11>',
        F12 = '<F12>',
      },
    },
    spec = {
      { '<leader>b', group = ' Buffers' },
      { '<leader>c', group = ' Code' },
      { '<leader>f', group = ' Find' },
      { '<leader>g', group = ' Git' },
      { '<leader>q', group = ' Quit/Session' },
      { '<leader>r', group = ' Rename', icon = '󰑕 ' },
      { '<leader>s', group = ' Search' },
      { '<leader>u', group = ' UI Toggles' },
      { '<leader>w', group = ' Windows' },
      { '<leader>x', group = ' Diagnostics' },
      { '<leader><tab>', group = ' Tabs' },
      -- Explicit icons for specific mappings
      { '<leader>e', icon = ' ' }, -- Explorer
      { '<leader>E', icon = ' ' }, -- Explorer
      { '<leader>l', icon = '💤 ' }, -- Lazy
      { '<leader>-', icon = ' ' }, -- Split Below
      { '<leader>\\', icon = ' ' }, -- Split Right
      { '<leader>:', icon = ' ' }, -- Command History
      { '<leader>h', icon = ' ' }, -- Check Health
    },
  },
}
