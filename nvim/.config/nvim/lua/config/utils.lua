-- [[ Helper Functions ]]
local M = {}

-- Absolute path to the Obsidian vault, which lives in iCloud Drive on macOS.
-- Set $OBSIDIAN_VAULT to override (e.g. on machines without iCloud).
M.obsidian_vault = function()
  local override = vim.env.OBSIDIAN_VAULT
  if override and override ~= '' then
    return vim.fn.expand(override)
  end

  return vim.fn.expand '~/Library/Mobile Documents/iCloud~md~obsidian/Documents/obi'
end

-- Find Neovim config files using telescope
M.find_config_files = function()
  require('telescope.builtin').find_files {
    cwd = vim.fn.stdpath 'config',
    prompt_title = 'Config Files',
  }
end

return M
