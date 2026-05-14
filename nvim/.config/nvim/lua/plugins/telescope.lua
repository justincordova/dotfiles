-- [[ Telescope Configuration ]]
return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', optional = true },
      { 'nvim-telescope/telescope-project.nvim' },
      { 'nanotee/zoxide.vim' }, -- Dependency for telescope-z
      { 'jvgrootveld/telescope-zoxide' },
      { 'rcarriga/nvim-notify' }, -- For notification history
    },
    keys = {
      { '<leader><space>', function() require('telescope.builtin').find_files() end, desc = 'Find Files' },
      { '<leader>ff', function() require('telescope.builtin').find_files() end, desc = 'Find Files' },
      { '<leader>fg', function() require('telescope.builtin').live_grep() end, desc = 'Live Grep' },
      { '<leader>fb', function() require('telescope.builtin').buffers() end, desc = 'Find Buffers' },
      { '<leader>fr', function() require('telescope.builtin').oldfiles() end, desc = 'Recent Files' },
      { '<leader>fh', function() require('telescope.builtin').help_tags() end, desc = 'Help Tags' },
      { '<leader>fk', function() require('telescope.builtin').keymaps() end, desc = 'Find Keymaps' },
      { '<leader>fc', function() require('config.utils').find_config_files() end, desc = 'Config Files' },
      { '<leader>fp', function() require('telescope').extensions.project.project() end, desc = 'Projects' },
      { '<leader>fz', function() require('telescope').extensions.zoxide.list() end, desc = 'Z Directories' },
      { '<leader>sw', function() require('telescope.builtin').grep_string() end, desc = 'Search word under cursor' },
      {
        '<leader>ut',
        function()
          require('telescope.builtin').colorscheme {
            enable_preview = true,
            attach_mappings = function(_, map)
              map('i', '<CR>', function(prompt_bufnr)
                local selection = require('telescope.actions.state').get_selected_entry()
                require('telescope.actions').close(prompt_bufnr)
                vim.cmd.colorscheme(selection.value)
              end)
              return true
            end,
          }
        end,
        desc = 'Toggle theme',
      },
    },
    config = function()
      local telescope = require 'telescope'
      local actions = require 'telescope.actions'

      telescope.setup {
        defaults = {
          mappings = {
            i = {
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
              ['<C-x>'] = actions.delete_buffer,
            },
          },
          file_ignore_patterns = {
            'node_modules',
            '.git/',
            'dist/',
            'build/',
            'target/',
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          project = {
            base_dirs = {
              '~/dotfiles',
            },
            hidden_files = true,
          },
          zoxide = {
            prompt_title = '[ Z Directories ]',
          },
        },
      }

      -- Load extensions
      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')
      pcall(telescope.load_extension, 'project')
      pcall(telescope.load_extension, 'zoxide')
      pcall(telescope.load_extension, 'notify')
    end,
  },
}
