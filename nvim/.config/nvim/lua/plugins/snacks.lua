return {
  "folke/snacks.nvim",
  priority = 1000,
  opts = {
    scroll = { enabled = false },
    notifier = { enabled = true },
    quickfile = {},
    picker = { enabled = true },
    input = { enabled = true },
    terminal = { enabled = true },
    sources = {
      explorer = {
        hidden = true,
        ignored = true,
      },
    },
    dashboard = { enabled = false },
  },
}
