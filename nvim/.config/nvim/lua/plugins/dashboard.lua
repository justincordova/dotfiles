-- [[ Dashboard Configuration ]]
return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  opts = function()
    local logo = [[
 ██████╗ ███████╗ █████╗ ███╗   ██╗███████╗
 ██╔══██╗██╔════╝██╔══██╗████╗  ██║██╔════╝
 ██████╔╝█████╗  ███████║██╔██╗ ██║███████╗
 ██╔══██╗██╔══╝  ██╔══██║██║╚██╗██║╚════██║
 ██████╔╝███████╗██║  ██║██║ ╚████║███████║
 ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝
    ]]
    logo = string.rep('\n', 8) .. logo .. string.rep('\n', 2)

    local opts = {
      theme = 'doom',
      hide = {
        statusline = false,
      },
      config = {
        header = vim.split(logo, '\n'),
        center = {
          { action = 'Telescope find_files', desc = ' Find file', icon = '󰈞 ', key = 'f' },
          { action = 'ene | startinsert', desc = ' New file', icon = '󰈔 ', key = 'n' },
          { action = 'Telescope oldfiles', desc = ' Recent files', icon = '󰋚 ', key = 'r' },
          { action = 'Telescope live_grep', desc = ' Find text', icon = '󰊄 ', key = 't' },
          { action = 'Telescope project', desc = ' Projects', icon = '󰉓 ', key = 'p' },
          { action = 'lua require("config.utils").find_config_files()', desc = ' Config', icon = '󰒓 ', key = 'v' },
          { action = function() require("persistence").load() end, desc = ' Restore Session', icon = '󰦛 ', key = 's' },
          { action = 'Lazy', desc = ' Lazy', icon = '󰒲 ', key = 'l' },
          { action = 'qa', desc = ' Quit', icon = '󰗼 ', key = 'q' },
        },
        footer = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return { '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms' }
        end,
      },
    }

    for _, button in ipairs(opts.config.center) do
      button.desc = button.desc .. string.rep(' ', 43 - #button.desc)
      button.key_format = '  %s'
    end

    -- Close Lazy and re-open when dashboard is ready
    if vim.o.filetype == 'lazy' then
      vim.cmd.close()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'DashboardLoaded',
        callback = function()
          require('lazy').show()
        end,
      })
    end

    return opts
  end,
  config = function(_, opts)
    require('dashboard').setup(opts)
    vim.api.nvim_set_hl(0, 'DashboardHeader', { fg = '#cba6f7' }) -- Mauve
    vim.api.nvim_set_hl(0, 'DashboardIcon', { fg = '#cba6f7' })   -- Mauve
    vim.api.nvim_set_hl(0, 'DashboardDesc', { fg = '#b4befe' })   -- Lavender
    vim.api.nvim_set_hl(0, 'DashboardKey', { fg = '#f5c2e7' })    -- Pink
  end,
}
