-- [[ LSP Configuration ]]
return {
  -- Main LSP Configuration
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      -- Mason for managing LSP servers
      { 'williamboman/mason.nvim', cmd = 'Mason', build = ':MasonUpdate', config = true },
      { 'williamboman/mason-lspconfig.nvim' },

      -- Useful status updates for LSP
      { 'j-hui/fidget.nvim', opts = {} },

      -- Lua LSP configuration for Neovim
      { 'folke/lazydev.nvim', ft = 'lua', opts = {} },
    },
    config = function()
      -- Diagnostic Config
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        virtual_text = {
          source = 'if_many',
          spacing = 4,
          prefix = '●',
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '✘',
            [vim.diagnostic.severity.WARN] = '▲',
            [vim.diagnostic.severity.HINT] = '⚑',
            [vim.diagnostic.severity.INFO] = '»',
          },
        },
      }

      -- This function runs when an LSP attaches to a buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- LSP keybindings
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>cd', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>cs', require('telescope.builtin').lsp_document_symbols, 'Document [S]ymbols')
          map('<leader>cw', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace Symbols')
          map('<leader>cr', vim.lsp.buf.rename, '[R]ename')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code [A]ction')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Highlight references on hover
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- Inlay hints toggle
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>ch', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, 'Toggle Inlay [H]ints')
          end
        end,
      })

      -- LSP servers and their configurations
      local servers = {
        angularls = {
          root_dir = require('lspconfig.util').root_pattern 'angular.json',
        },
        bashls = {},
        clangd = {},
        cssls = {},
        dockerls = {},
        emmet_ls = {},
        eslint = {
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
          end,
        },
        gopls = {},
        graphql = {},
        html = {},
        jsonls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              diagnostics = {
                globals = { 'vim' },
              },
            },
          },
        },
        omnisharp = {},
        postgres_lsp = {},
        prismals = {},
        pyright = {},
        ruff = {},
        rust_analyzer = {},
        tailwindcss = {},
        taplo = {},
        vtsls = {},
      }

      -- Setup default capabilities for completion
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())

      -- Setup Mason
      require('mason').setup()

      -- Setup mason-lspconfig with handlers (modern approach for Neovim 0.11+)
      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
        handlers = {
          -- Default handler for all servers
          function(server_name)
            local server_config = servers[server_name] or {}
            server_config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server_config.capabilities or {})
            require('lspconfig')[server_name].setup(server_config)
          end,
        },
      }
    end,
  },
}
