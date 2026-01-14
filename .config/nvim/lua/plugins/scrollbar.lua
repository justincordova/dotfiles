-- [[ Scrollbar with Diagnostics ]]
return {
  'petertriho/nvim-scrollbar',
  event = 'VeryLazy',
  dependencies = {
    'lewis6991/gitsigns.nvim',
  },
  opts = {
    show = true,
    handle = {
      color = '#3b4261',
    },
    marks = {
      Search = { color = '#ff9e64' },
      Error = { color = '#db4b4b' },
      Warn = { color = '#e0af68' },
      Info = { color = '#0db9d7' },
      Hint = { color = '#1abc9c' },
      Misc = { color = '#9d7cd8' },
      GitAdd = { color = '#449dab' },
      GitChange = { color = '#6183bb' },
      GitDelete = { color = '#914c54' },
    },
    handlers = {
      cursor = true,
      diagnostic = true,
      gitsigns = true,
      handle = true,
      search = false, -- Disabled: requires nvim-hlslens plugin
    },
  },
}
