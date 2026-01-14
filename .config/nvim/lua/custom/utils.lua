-- [[ Helper Functions ]]
local M = {}

-- Find Neovim config files using telescope
M.find_config_files = function()
  require('telescope.builtin').find_files {
    cwd = vim.fn.stdpath 'config',
    prompt_title = 'Config Files',
  }
end

-- Save current colorscheme to file for persistence
M.save_colorscheme = function(colorscheme)
  local config_dir = vim.fn.stdpath 'config'
  local colorscheme_file = config_dir .. '/lua/custom/colorscheme.txt'
  local file = io.open(colorscheme_file, 'w')
  if file then
    file:write(colorscheme)
    file:close()
  end
end

-- Load saved colorscheme
M.load_saved_colorscheme = function()
  local config_dir = vim.fn.stdpath 'config'
  local colorscheme_file = config_dir .. '/lua/custom/colorscheme.txt'
  local file = io.open(colorscheme_file, 'r')
  if file then
    local colorscheme = file:read '*a'
    file:close()
    return colorscheme:gsub('%s+', '') -- trim whitespace
  end
  return nil
end

return M
