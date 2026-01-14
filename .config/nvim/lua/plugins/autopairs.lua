-- [[ Auto Pairs ]]
return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  config = function()
    local npairs = require 'nvim-autopairs'
    npairs.setup {
      check_ts = true,
      ts_config = {
        lua = { 'string' },
        javascript = { 'template_string' },
        java = false,
      },
      disable_filetype = { 'TelescopePrompt', 'vim' },
      fast_wrap = {
        map = '<M-e>',
        chars = { '{', '[', '(', '"', "'" },
        pattern = [=[[%'%"%)%>%]%)%}%,]]=],
        end_key = '$',
        keys = 'qwertyuiopzxcvbnmasdfghjkl',
        check_comma = true,
        highlight = 'Search',
        highlight_grey = 'Comment',
      },
    }
  end,
}
