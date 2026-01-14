-- [[ Linting with nvim-lint ]]
return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'

    lint.linters_by_ft = {
      javascript = { 'eslint' },
      typescript = { 'eslint' },
      javascriptreact = { 'eslint' },
      typescriptreact = { 'eslint' },
      python = { 'pylint', 'mypy' },
      sh = { 'shellcheck' },
      bash = { 'shellcheck' },
      dockerfile = { 'hadolint' },
      gitcommit = { 'gitlint' },
      -- markdown = { 'vale' },
    }

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
