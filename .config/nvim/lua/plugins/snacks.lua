return {
  "folke/snacks.nvim",
  opts = {
    scroll = { enabled = true },
    notifier = { enabled = true },
    quickfile = {},
    picker = {
      hidden = true,
      ignored = true,
    },
    sources = {
      explorer = {
        hidden = true,
        ignored = true,
      },
    },
    dashboard = {
      enabled = true,
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
      preset = {
        header = [[
 ██████╗ ███████╗ █████╗ ███╗   ██╗███████╗
 ██╔══██╗██╔════╝██╔══██╗████╗  ██║██╔════╝
 ██████╔╝█████╗  ███████║██╔██╗ ██║███████╗
 ██╔══██╗██╔══╝  ██╔══██║██║╚██╗██║╚════██║
 ██████╔╝███████╗██║  ██║██║ ╚████║███████║
 ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝]],
      },
    },
  },
}