-- [[ Helper Functions ]]
local M = {}

-- Find Neovim config files using telescope
M.find_config_files = function()
  require('telescope.builtin').find_files {
    cwd = vim.fn.stdpath 'config',
    prompt_title = 'Config Files',
  }
end

return M
