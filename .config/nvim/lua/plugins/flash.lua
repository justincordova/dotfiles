-- [[ Flash - Enhanced Navigation ]]
-- Jump anywhere on screen with 2 keystrokes
return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {
    -- Labels to use for jump targets
    labels = 'asdfghjklqwertyuiopzxcvbnm',
    -- Search configuration
    search = {
      -- Search mode: exact, search, fuzzy
      mode = 'exact',
      -- Behave like `incsearch`
      incremental = false,
    },
    -- Jump configuration
    jump = {
      -- Save location in the jumplist
      jumplist = true,
      -- Jump position
      pos = 'start',
      -- Automatically jump when there is only one match
      autojump = false,
    },
    -- Label configuration
    label = {
      -- Show labels after the match
      after = true,
      -- Show labels before the match
      before = false,
      -- Style: inline, overlay, eol
      style = 'overlay',
      -- Minimum pattern length to show labels
      min_pattern_length = 0,
    },
    -- Highlight configuration
    highlight = {
      -- Show a backdrop with hl FlashBackdrop
      backdrop = true,
      -- Highlight matches
      matches = true,
    },
    modes = {
      -- Options for flash search mode
      search = {
        enabled = true,
      },
      -- Options for character search (f, F, t, T, ;, ,)
      char = {
        enabled = true,
        -- Jump on the first match
        autohide = false,
        -- Show jump labels
        jump_labels = false,
      },
      -- Options for treesitter search
      treesitter = {
        labels = 'abcdefghijklmnopqrstuvwxyz',
        jump = { pos = 'range' },
        highlight = {
          backdrop = false,
          matches = false,
        },
      },
    },
  },
  keys = {
    {
      's',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').jump()
      end,
      desc = 'Flash',
    },
    {
      'S',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').treesitter()
      end,
      desc = 'Flash Treesitter',
    },
    {
      'r',
      mode = 'o',
      function()
        require('flash').remote()
      end,
      desc = 'Remote Flash',
    },
    {
      'R',
      mode = { 'o', 'x' },
      function()
        require('flash').treesitter_search()
      end,
      desc = 'Treesitter Search',
    },
    {
      '<c-s>',
      mode = { 'c' },
      function()
        require('flash').toggle()
      end,
      desc = 'Toggle Flash Search',
    },
  },
}
