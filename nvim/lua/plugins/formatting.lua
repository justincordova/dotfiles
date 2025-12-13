return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "prettierd",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = function(_, opts)
      -- Define the filetypes that should use prettierd
      local prettier_fts = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "css",
        "scss",
        "less",
        "html",
        "json",
        "jsonc",
        "yaml",
        "markdown",
        "markdown_inline",
        "graphql",
        "handlebars",
      }

      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(prettier_fts) do
        opts.formatters_by_ft[ft] = { "prettierd" }
      end

    end,
    init = function()
      -- Create the :Format command
      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        require("conform").format({ async = true, lsp_fallback = true, range = range })
      end, { range = true })
    end,
  },
}
