-- [[ Scrollbar ]]
return {
  'petertriho/nvim-scrollbar',
  event = 'VeryLazy',
  opts = {
    show = true,
    handle = {
      color = '#3b4261',
    },
    handlers = {
      cursor = true,
      diagnostic = false,
      gitsigns = false,
      handle = true,
      search = false,
    },
  },
}
