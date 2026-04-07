return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    config = function()
      local ensure_installed = {
        'bash',
        'c',
        'c_sharp',
        'cpp',
        'css',
        'dockerfile',
        'go',
        'graphql',
        'html',
        'java',
        'javascript',
        'json',
        'lua',
        'markdown',
        'markdown_inline',
        'prisma',
        'python',
        'regex',
        'rust',
        'sql',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'xml',
        'yaml',
      }

      require('nvim-treesitter').setup()

      local installed = require('nvim-treesitter.config').get_installed('parsers')
      local to_install = vim.tbl_filter(function(p)
        return not vim.tbl_contains(installed, p)
      end, ensure_installed)
      if #to_install > 0 then
        require('nvim-treesitter').install(to_install)
      end

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft) or ft
          if vim.tbl_contains(require('nvim-treesitter.config').get_installed('parsers'), lang) then
            pcall(vim.treesitter.start, args.buf, lang)
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local select = require('nvim-treesitter-textobjects.select')
      local move = require('nvim-treesitter-textobjects.move')

      for _, mapping in ipairs {
        { 'af', '@function.outer' },
        { 'if', '@function.inner' },
        { 'ac', '@class.outer' },
        { 'ic', '@class.inner' },
        { 'al', '@loop.outer' },
        { 'il', '@loop.inner' },
        { 'aa', '@parameter.outer' },
        { 'ia', '@parameter.inner' },
      } do
        vim.keymap.set({ 'o', 'x' }, mapping[1], function()
          select.select_textobject(mapping[2])
        end, { buffer = true })
      end

      for _, mapping in ipairs {
        { ']f', move.goto_next_start, '@function.outer' },
        { ']c', move.goto_next_start, '@class.outer' },
        { ']F', move.goto_next_end, '@function.outer' },
        { ']C', move.goto_next_end, '@class.outer' },
        { '[f', move.goto_previous_start, '@function.outer' },
        { '[c', move.goto_previous_start, '@class.outer' },
        { '[F', move.goto_previous_end, '@function.outer' },
        { '[C', move.goto_previous_end, '@class.outer' },
      } do
        vim.keymap.set('n', mapping[1], function()
          mapping[2](mapping[3])
        end)
      end
    end,
  },
}
