-- [[ Git Conflict Resolution ]]
return {
  'akinsho/git-conflict.nvim',
  version = '*',
  event = 'BufReadPre',
  opts = {
    default_mappings = true, -- co=ours, ct=theirs, cb=both, c0=none, ]x/[x=next/prev
    default_commands = true,
    disable_diagnostics = false,
    list_opener = 'copen',
    highlights = {
      incoming = 'DiffAdd',
      current = 'DiffText',
    },
  },
}
