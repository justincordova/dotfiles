-- [[ Debug Adapter Protocol ]]
return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- DAP UI
      {
        'rcarriga/nvim-dap-ui',
        dependencies = { 'nvim-neotest/nvim-nio' },
        config = function()
          local dap = require 'dap'
          local dapui = require 'dapui'
          dapui.setup()

          -- Auto-open/close UI on debug events
          dap.listeners.after.event_initialized['dapui_config'] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated['dapui_config'] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited['dapui_config'] = function()
            dapui.close()
          end
        end,
      },

      -- Inline variable values during debugging
      {
        'theHamsta/nvim-dap-virtual-text',
        opts = {},
      },

      -- Auto-install debug adapters via Mason
      {
        'jay-babu/mason-nvim-dap.nvim',
        dependencies = { 'williamboman/mason.nvim' },
        opts = {
          ensure_installed = {
            'python',
            'delve', -- Go
            'codelldb', -- Rust, C, C++
            'js', -- TypeScript/JavaScript
          },
          automatic_installation = true,
          handlers = {
            function(config)
              require('mason-nvim-dap').default_setup(config)
            end,
          },
        },
      },
    },
    keys = {
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Toggle breakpoint' },
      { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = 'Conditional breakpoint' },
      { '<leader>dc', function() require('dap').continue() end, desc = 'Continue' },
      { '<leader>ds', function() require('dap').step_over() end, desc = 'Step over' },
      { '<leader>di', function() require('dap').step_into() end, desc = 'Step into' },
      { '<leader>do', function() require('dap').step_out() end, desc = 'Step out' },
      { '<leader>dr', function() require('dap').repl.open() end, desc = 'Open REPL' },
      { '<leader>dl', function() require('dap').run_last() end, desc = 'Run last' },
      { '<leader>dt', function() require('dap').terminate() end, desc = 'Terminate' },
      { '<leader>du', function() require('dapui').toggle() end, desc = 'Toggle DAP UI' },
      { '<leader>de', function() require('dapui').eval() end, mode = { 'n', 'v' }, desc = 'Eval expression' },
    },
    config = function()
      local dap = require 'dap'

      -- Signs
      vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticError', linehl = '', numhl = '' })
      vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticWarn', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticInfo', linehl = 'DapStoppedLine', numhl = '' })
      vim.fn.sign_define('DapBreakpointRejected', { text = '○', texthl = 'DiagnosticError', linehl = '', numhl = '' })

      -- TypeScript/JavaScript (via js-debug-adapter)
      for _, adapter in ipairs { 'pwa-node' } do
        dap.adapters[adapter] = {
          type = 'server',
          host = 'localhost',
          port = '${port}',
          executable = {
            command = 'node',
            args = {
              vim.fn.stdpath 'data' .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js',
              '${port}',
            },
          },
        }
      end

      for _, lang in ipairs { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' } do
        dap.configurations[lang] = {
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch file',
            program = '${file}',
            cwd = '${workspaceFolder}',
          },
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
          },
        }
      end
    end,
  },
}
