-- [[ Obsidian Integration ]]
return {
  'epwalsh/obsidian.nvim',
  version = '*',
  lazy = true,
  ft = 'markdown',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  opts = {
    ui = { enable = false },
    workspaces = {
      {
        name = 'obi',
        path = '/Users/justincordova/Library/Mobile Documents/iCloud~md~obsidian/Documents/obi',
      },
    },
    daily_notes = {
      folder = 'daily',
      date_format = '%Y-%m-%d',
      template = nil,
    },
    completion = {
      nvim_cmp = false, -- Disable nvim-cmp integration
      min_chars = 2,
    },
    mappings = {
      ['gf'] = {
        action = function()
          return require('obsidian').util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      ['<leader>ch'] = {
        action = function()
          return require('obsidian').util.toggle_checkbox()
        end,
        opts = { buffer = true },
      },
    },
    note_id_func = function(title)
      local suffix = ''
      if title ~= nil then
        suffix = title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
      else
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return tostring(os.time()) .. '-' .. suffix
    end,
    -- Templates configuration (disabled - folder doesn't exist)
    -- Create the folder in your vault if you want to use templates
    -- templates = {
    --   subdir = 'templates',
    --   date_format = '%Y-%m-%d',
    --   time_format = '%H:%M',
    -- },
    follow_url_func = function(url)
      vim.fn.jobstart { 'open', url }
    end,
  },
}
