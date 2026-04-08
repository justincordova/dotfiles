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
    init = function()
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
    end,
    config = function()
      -- This function runs when an LSP attaches to a buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = false }),
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
          vim.keymap.set('n', '<leader>cr', function()
            return ':IncRename ' .. vim.fn.expand '<cword>'
          end, { buffer = event.buf, expr = true, desc = 'LSP: [R]ename' })
          map('<leader>ca', vim.lsp.buf.code_action, 'Code [A]ction')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Highlight references on hover
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>ci', function()
              vim.lsp.inlay_hint.enable(
                not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf },
                { bufnr = event.buf }
              )
            end, 'Toggle [I]nlay Hints')
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
          end
        end,
      })

      -- Servers to install via Mason and auto-enable via vim.lsp.enable()
      local servers = {
        'angularls',
        'bashls',
        'clangd',
        'cssls',
        'dockerls',
        'docker_compose_language_service',
        'emmet_ls',
        'eslint',
        'gopls',
        'jdtls',
        'graphql',
        'html',
        'jsonls',
        'lua_ls',
        'omnisharp',
        'postgres_lsp',
        'prismals',
        'pyright',
        'ruff',
        'rust_analyzer',
        'tailwindcss',
        'taplo',
        'vtsls',
      }

      -- Default capabilities for every server (blink.cmp + Neovim defaults)
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      vim.lsp.config('*', { capabilities = capabilities })

      -- Per-server overrides via vim.lsp.config (Neovim 0.11+ API)
      vim.lsp.config('angularls', {
        root_markers = { 'angular.json' },
      })

      vim.lsp.config('eslint', {
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
        end,
      })

      vim.lsp.config('gopls', {
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            staticcheck = true,
          },
        },
      })

      vim.lsp.config('lua_ls', {
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
      })

      -- Mason + mason-lspconfig v2: ensure_installed + automatic_enable only
      require('mason').setup()
      require('mason-lspconfig').setup {
        ensure_installed = servers,
        automatic_enable = true,
      }
    end,
  },
}
