-- [[ Linting with nvim-lint ]]
return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'

    lint.linters_by_ft = {
      -- eslint is handled by the eslint LSP server (see lsp.lua)
      -- ruff is handled by the ruff LSP server (see lsp.lua)
      -- shellcheck is handled by bashls LSP server (see lsp.lua)
      python = { 'mypy' },
      dockerfile = { 'hadolint' },
      gitcommit = { 'gitlint' },
      go = { 'golangcilint' },
      -- markdown = { 'vale' },
    }

    lint.linters.golangcilint.ignore_exitcode = true

    -- Auto-lint on save and text change
    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
        -- Also lint with typos if available
        pcall(lint.try_lint, 'typos')
      end,
    })
  end,
}
