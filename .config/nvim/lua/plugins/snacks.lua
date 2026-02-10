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
    dashboard = {
      enabled = true,
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        {
          icon = " ",
          title = "Git Status",
          section = "terminal",
          cmd = "git status --short --branch --renames 2>/dev/null || echo 'N/A'",
          height = 5,
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
        },
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
        keys = {
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
  },
}
