return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    cmd = { "RenderMarkdown" },
    ft = { "markdown", "norg", "rmd", "org" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      preset = "lazy",
      latex = { enabled = false },
      -- Ensure it runs on markdown filetype (which we'll force for .MD)
      file_types = { "markdown", "norg", "rmd", "org" },
    },
    init = function()
      -- Force .MD files to be treated as markdown if they aren't already
      vim.filetype.add({
        extension = {
          MD = "markdown",
        },
      })
    end,
  },
}
