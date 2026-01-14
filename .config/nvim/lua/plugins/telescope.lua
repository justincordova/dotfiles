-- [[ Telescope Configuration ]]
return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
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
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
      { 'nvim-telescope/telescope-project.nvim' },
      { 'nanotee/zoxide.vim' }, -- Dependency for telescope-z
      { 'jvgrootveld/telescope-zoxide' },
      { 'rcarriga/nvim-notify' }, -- For notification history
    },
    config = function()
      local telescope = require 'telescope'
      local actions = require 'telescope.actions'
      local builtin = require 'telescope.builtin'

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

      -- Telescope keybindings (Leader f - Find)
      vim.keymap.set('n', '<leader><space>', builtin.find_files, { desc = 'Find Files (Root)' })
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live Grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find Buffers' })
      vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent Files' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help Tags' })
      vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Find Keymaps' })
      vim.keymap.set('n', '<leader>fc', require('custom.utils').find_config_files, { desc = 'Config Files' })
      vim.keymap.set('n', '<leader>fp', telescope.extensions.project.project, { desc = 'Projects' })
      vim.keymap.set('n', '<leader>fz', telescope.extensions.zoxide.list, { desc = 'Z Directories' })
      vim.keymap.set('n', '<leader>bb', builtin.buffers, { desc = 'List Buffers' })

      -- Colorscheme switcher with preview and persistence
      vim.keymap.set('n', '<leader>ut', function()
        builtin.colorscheme {
          enable_preview = true,
          attach_mappings = function(_, map)
            map('i', '<CR>', function(prompt_bufnr)
              local selection = require('telescope.actions.state').get_selected_entry()
              require('telescope.actions').close(prompt_bufnr)
              vim.cmd.colorscheme(selection.value)
              -- Save the selected colorscheme
              require('custom.utils').save_colorscheme(selection.value)
            end)
            return true
          end,
        }
      end, { desc = 'Toggle theme' })

      -- Search word under cursor
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = 'Search word under cursor' })
    end,
  },
}
