-- [[ Wrapping: Soft/Hard Line Wrapping ]]
-- Automatically detects and configures optimal wrapping for text/markdown files
-- Provides toggle commands for switching between soft and hard wrap modes
return {
  'andrewferrier/wrapping.nvim',
  ft = { 'markdown', 'text', 'asciidoc', 'latex' },
  config = function()
    require('wrapping').setup({
      -- Customize which filetypes auto-detect wrapping mode
      auto_set_mode_filetype_allowlist = {
        'markdown',
        'text',
        'asciidoc',
        'gitcommit',
        'latex',
        'rst',
        'tex',
        'mail',
      },
      -- Force soft wrap for specific filetypes (paragraphs as single lines)
      softener = {
        markdown = true,    -- Always soft wrap markdown
        text = true,        -- Always soft wrap plain text
        asciidoc = true,    -- Always soft wrap asciidoc
        gitcommit = true,     -- Always soft wrap git commits
        rst = true,          -- Always soft wrap reStructuredText
        mail = true,         -- Always soft wrap emails
      },
      -- Ensure wrapping breaks only at word boundaries (not mid-word)
      set_nvim_opt_defaults = true,
    })
  end,
}
