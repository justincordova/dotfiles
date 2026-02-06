local M = {}

local scratch_path = vim.fn.expand "~/SCRATCH.md"
local fleeting_dir = vim.fn.expand "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/obi/50 Fleeting"

local function ensure_scratch_file()
  if vim.fn.filereadable(scratch_path) == 0 then
    vim.fn.writefile({ "" }, scratch_path)
  end
end

local function find_scratch_buffer()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      local name = vim.api.nvim_buf_get_name(bufnr)
      if name == scratch_path then
        return bufnr
      end
    end
  end
  return nil
end

local function slugify_title(title)
  if not title then
    return ""
  end

  local slug = title:lower()
  slug = slug:gsub("%s+", "-")
  slug = slug:gsub("[^%w%-_]", "")
  slug = slug:gsub("-+", "-")
  slug = slug:gsub("^%-", "")
  slug = slug:gsub("%-$", "")

  return slug
end

local function unique_path(base_dir, filename)
  local path = string.format("%s/%s", base_dir, filename)
  if vim.fn.filereadable(path) == 0 then
    return path
  end

  local stamp = os.date "%H%M%S"
  local name = filename:gsub("%.md$", "")
  local with_stamp = string.format("%s_%s.md", name, stamp)
  return string.format("%s/%s", base_dir, with_stamp)
end

function M.open()
  ensure_scratch_file()
  vim.schedule(function()
    vim.cmd("edit " .. vim.fn.fnameescape(scratch_path))
  end)
end

function M.export()
  ensure_scratch_file()

  if vim.fn.isdirectory(fleeting_dir) == 0 then
    vim.notify("Fleeting dir missing: " .. fleeting_dir, vim.log.levels.ERROR, { title = "Scratch" })
    return
  end

  local lines = nil
  local scratch_bufnr = find_scratch_buffer()
  if scratch_bufnr then
    vim.api.nvim_buf_call(scratch_bufnr, function()
      if vim.bo.modified then
        vim.cmd "silent write"
      end
    end)
    lines = vim.api.nvim_buf_get_lines(scratch_bufnr, 0, -1, false)
  else
    if vim.fn.filereadable(scratch_path) == 1 then
      lines = vim.fn.readfile(scratch_path)
    else
      lines = {}
    end
  end

  local date_prefix = os.date "%Y-%m-%d"

  vim.ui.input({ prompt = "Scratch title: " }, function(input)
    local slug = slugify_title(input)
    if slug == "" then
      slug = "scratch"
    end

    local filename = string.format("%s_%s.md", date_prefix, slug)
    local dest_path = unique_path(fleeting_dir, filename)

    local id = filename:gsub("%.md$", "")
    local frontmatter = {
      "---",
      "id: " .. id,
      "aliases: []",
      "tags: []",
      "---",
      "",
    }

    if not lines then
      lines = {}
    end

    local output = vim.list_extend(frontmatter, lines)

    local ok, err = pcall(vim.fn.writefile, output, dest_path)
    if not ok then
      vim.notify("Failed to write: " .. dest_path .. " (" .. tostring(err) .. ")", vim.log.levels.ERROR, { title = "Scratch" })
      return
    end

    vim.notify("Exported scratch to " .. dest_path, vim.log.levels.INFO, { title = "Scratch" })
  end)
end

function M.search_fleeting()
  local builtin = require "telescope.builtin"
  builtin.find_files {
    prompt_title = "[ Fleeting ]",
    cwd = fleeting_dir,
    previewer = true,
    layout_strategy = "horizontal",
    layout_config = {
      preview_width = 0.6,
    },
  }
end

function M.setup()
  vim.api.nvim_create_user_command("Scratch", function()
    M.open()
  end, {})

  vim.api.nvim_create_user_command("NvimScratch", function()
    M.open()
  end, {})

  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      local args = vim.fn.argv()
      if #args ~= 1 then
        return
      end

      local name = vim.fn.fnamemodify(args[1], ":t")
      if name == "scratch" or name == "SCRATCH" then
        local start_buf = vim.api.nvim_get_current_buf()
        vim.bo[start_buf].buflisted = false
        vim.bo[start_buf].bufhidden = "hide"
        M.open()
      end
    end,
  })
end

return M
