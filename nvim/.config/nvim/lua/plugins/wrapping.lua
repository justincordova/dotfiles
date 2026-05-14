-- [[ Wrapping: Soft/Hard Line Wrapping ]]
-- Automatically detects and configures optimal wrapping for text/markdown files
-- Provides toggle commands for switching between soft and hard wrap modes
return {
  'andrewferrier/wrapping.nvim',
  ft = { 'markdown', 'text', 'asciidoc', 'gitcommit', 'latex', 'rst', 'tex', 'mail' },
  opts = {
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
      asciidoc = false,   -- Hard wrap asciidoc by default
      gitcommit = false,  -- Hard wrap git commits by default
      rst = false,        -- Hard wrap reStructuredText by default
      mail = false,       -- Hard wrap emails by default
    },
    -- Ensure wrapping breaks only at word boundaries (not mid-word)
    set_nvim_opt_defaults = true,
  },
}
