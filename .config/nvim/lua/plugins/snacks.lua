return {
  "folke/snacks.nvim",
  priority = 1000,
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
        -- Pinned Directories
        function()
          local pins = require("config.pins")
          local items = {}
          table.insert(items, { icon = " ", text = "Pinned Directories", indent = 2, padding = 1 })
          for i, pin in ipairs(pins) do
            local item = {
              icon = " ",
              key = pin.key,
              desc = pin.label,
              indent = 2,
              action = function()
                local path = vim.fn.expand(pin.path)
                vim.cmd("cd " .. path)
                vim.cmd("edit .")
              end,
            }
            -- Add padding to the last item to create space before the keys
            if i == #pins then
              item.padding = 2
            end
            table.insert(items, item)
          end
          return items
        end,
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