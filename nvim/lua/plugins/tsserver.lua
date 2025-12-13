return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    local lspconfig = require("lspconfig")
    opts.servers = opts.servers or {}
    opts.servers.tsserver = {
      root_dir = function(fname)
        return lspconfig.util.root_pattern("tsconfig.json", "package.json")(fname) or vim.loop.cwd()
      end,
    }
  end,
}