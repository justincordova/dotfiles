-- [[ Which-Key Configuration ]]
-- Note: Healthcheck warnings about overlapping keymaps for gc/gcc, gb/gbc, ys/yss, yS/ySS
-- are INTENTIONAL and expected. These plugins use Vim's timeout mechanism for multi-key
-- sequences. These are informational warnings, not errors that need fixing.
return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  dependencies = {
    { 'nvim-tree/nvim-web-devicons', optional = true },
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
        { pattern = "fold", icon = " ", color = "purple" },
        { pattern = "Fold", icon = " ", color = "purple" },
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
      { '<leader>d', group = ' Debug' },
      { '<leader>f', group = ' Find' },
      { '<leader>g', group = ' Git' },
      { '<leader>o', group = ' Octo/GitHub' },
      { '<leader>q', group = ' Quit/Session' },
      { '<leader>s', group = ' Search/Scratch' },
      { '<leader>w', group = ' Windows' },
      { '<leader>u', group = ' UI Toggles' },
      { '<leader>x', group = ' Diagnostics' },
      { '<leader>z', group = 'Folding', icon = '󰘖 ' },
      { '<M-,>', desc = 'Previous buffer', icon = '󰓩 ' },
      { '<M-.>', desc = 'Next buffer', icon = '󰓩 ' },
      { '<M-<>', desc = 'Move buffer left', icon = '󰓩 ' },
      { '<M->>', desc = 'Move buffer right', icon = '󰓩 ' },
      { '<M-1>', desc = 'Goto buffer 1', icon = '󰓩 ' },
      { '<M-2>', desc = 'Goto buffer 2', icon = '󰓩 ' },
      { '<M-3>', desc = 'Goto buffer 3', icon = '󰓩 ' },
      { '<M-4>', desc = 'Goto buffer 4', icon = '󰓩 ' },
      { '<M-5>', desc = 'Goto buffer 5', icon = '󰓩 ' },
      { '<M-6>', desc = 'Goto buffer 6', icon = '󰓩 ' },
      { '<M-7>', desc = 'Goto buffer 7', icon = '󰓩 ' },
      { '<M-8>', desc = 'Goto buffer 8', icon = '󰓩 ' },
      { '<M-9>', desc = 'Goto buffer 9', icon = '󰓩 ' },
      { '<M-0>', desc = 'Goto last buffer', icon = '󰓩 ' },
      { '<M-p>', desc = 'Pin buffer', icon = '󰓩 ' },
      { '<M-c>', desc = 'Close buffer', icon = '󰓩 ' },
      { '<C-s-p>', desc = 'Pick & delete buffer', icon = '󰓩 ' },

      -- Explicit icons for specific mappings
      { '<leader>e', icon = ' ' }, -- Explorer
      { '<leader>E', icon = ' ' }, -- Explorer
      { '<leader>l', icon = '💤 ' }, -- Lazy
      { '<leader>-', icon = ' ' }, -- Split Below
      { '<leader>\\', icon = ' ' }, -- Split Right
      { '<leader>:', icon = ' ' }, -- Command History
      { '<leader>h', icon = ' ' }, -- Check Health
      { '<leader><space>', desc = 'Find files', icon = '󰈞 ' },
      { '<leader>,', desc = 'Switch buffer', icon = '󰓩 ' },
      { '<leader>.', desc = 'Notification history', icon = '󰦨 ' },
      { '<leader>p', desc = 'Yank history', icon = '󰅇 ' },
      -- Folding keybindings (basic vim + nvim-ufo enhanced)
      { 'z', group = 'Fold' },
      { 'za', desc = 'Toggle fold' },
      { 'zo', desc = 'Open fold' },
      { 'zc', desc = 'Close fold' },
      { 'zO', desc = 'Open fold recursively' },
      { 'zC', desc = 'Close fold recursively' },
      { 'zR', desc = 'Open all folds' },
      { 'zM', desc = 'Close all folds' },
      { 'zr', desc = 'Fold less' },
      { 'zm', desc = 'Fold more' },
      { 'zp', desc = 'Peek fold' },
      -- Wrapping keybindings (from wrapping.nvim plugin)
      { '[ou', desc = 'Soft wrap mode', icon = '󰗘 ' },
      { ']ou', desc = 'Hard wrap mode', icon = '󰙘 ' },
      { 'you', desc = 'Toggle wrap mode', icon = '󰘚 ' },
      -- UI toggles
      { '<leader>ua', desc = 'Toggle auto-save' },
      { '<leader>ud', desc = 'Dismiss all notifications' },
      -- Code (LSP)
      { '<leader>ci', desc = 'Toggle inlay hints' },
      -- Debug
      { '<leader>db', desc = 'Toggle breakpoint' },
      { '<leader>dB', desc = 'Conditional breakpoint' },
      { '<leader>dc', desc = 'Continue' },
      { '<leader>ds', desc = 'Step over' },
      { '<leader>di', desc = 'Step into' },
      { '<leader>do', desc = 'Step out' },
      { '<leader>dr', desc = 'Open REPL' },
      { '<leader>dl', desc = 'Run last' },
      { '<leader>dt', desc = 'Terminate' },
      { '<leader>du', desc = 'Toggle DAP UI' },
      { '<leader>de', desc = 'Eval expression' },
      { '<leader>y', desc = 'Copy file to clipboard', icon = '󰆏 ' },
      { '<leader>?', desc = 'Keybind cheatsheet', icon = '󰌌 ' },
    },
  },
}
