# Neovim Config Rehaul Design

**Date:** 2026-01-12
**Goal:** Complete rehaul from LazyVim distro to clean kickstart-based minimal setup

---

## Problem Statement

Current config uses LazyVim distro which:
- Includes hundreds of default keybindings (which-key overwhelm)
- Has hidden defaults and "magic" configuration
- Bundles too many features in single plugins (e.g., snacks.nvim)
- Makes it hard to understand what's actually configured

**Solution:** Rebuild from kickstart foundation with explicit, modular configuration.

---

## Architecture

### Core Principles
1. **Pure lazy.nvim** - No LazyVim dependency
2. **One plugin per file** - Explicit configuration for each plugin
3. **Minimal which-key** - Only show user-defined keybindings
4. **Modular separation** - Separate plugins for separate concerns

### Directory Structure
```
dotfiles/.config/nvim/
├── init.lua                    # Bootstrap lazy.nvim, load custom modules
├── lazy-lock.json              # Lock file
├── stylua.toml                 # Formatting config
└── lua/
    ├── custom/
    │   ├── options.lua         # Vim options
    │   ├── keymaps.lua         # Core keymaps
    │   ├── autocmds.lua        # Autocommands
    │   └── utils.lua           # Helper functions
    └── plugins/
        └── [35-40 plugin files] # One file per plugin/feature
```

**Key Changes:**
- `lua/config/` → `lua/custom/` (kickstart alignment)
- Remove LazyVim import from lazy.nvim setup
- Each plugin explicitly configured

---

## Plugin Architecture (35-40 plugins)

### Core Infrastructure (4)
- `lazy.nvim` - Plugin manager
- `plenary.nvim` - Dependency library
- `nvim-web-devicons` - Icons
- `nui.nvim` - UI components

### LSP & Completion (5)
- `nvim-lspconfig` - LSP configuration
- `mason.nvim` - LSP/tool installer
- `mason-lspconfig.nvim` - Bridge between mason and lspconfig
- `blink.cmp` - Completion engine (Rust-based, fast)
- `lazydev.nvim` - Lua LSP enhancement

**Language Servers to Configure:**
- angular-language-server, bash-language-server, clangd
- css-lsp, docker-language-server, emmet-ls, eslint-lsp
- gopls, graphql-language-service-cli, html-lsp, jdtls
- json-lsp, lua-language-server, omnisharp, postgres-language-server
- prisma-language-server, pyright, rust-analyzer, sqls
- tailwindcss-language-server, typescript-language-server, vtsls

### Formatting & Linting (2)
- `conform.nvim` - Formatting
- `nvim-lint` - Linting

**Configuration:**
- Format on save: Enabled by default
- Auto-save: Timer-based (2s idle) + focus-lost
- Formatters: prettierd, stylua, black, gofmt, rustfmt, isort, ruff, shfmt, sql-formatter, clang-format
- Linters: eslint, pylint, mypy, dotenv-linter, hadolint, gitlint, vale, typos

### Treesitter (2)
- `nvim-treesitter` - Syntax parsing
- `nvim-treesitter-textobjects` - Enhanced motions

**Parsers:**
typescript, tsx, javascript, jsx, python, lua, rust, go, c_sharp, html, css, json, yaml, toml, bash, dockerfile, graphql, markdown, markdown_inline, c, cpp, java, sql, prisma, vim, regex

**Features:**
- Auto-install parsers
- Syntax highlighting
- Indentation
- Incremental selection
- NO rainbow brackets

### Telescope & Extensions (5)
- `telescope.nvim` - Fuzzy finder
- `telescope-fzf-native.nvim` - Faster sorting
- `telescope-ui-select.nvim` - UI replacement
- `telescope-project.nvim` - Project management
- `telescope-z.nvim` - Z integration

### Git (3)
- `lazygit.nvim` - Lazygit integration (primary git UI)
- `gitsigns.nvim` - Inline git info, hunk operations
- `diffview.nvim` - Side-by-side diff viewer

**Workflow:**
- Lazygit for commits, branches, complex operations
- Gitsigns for quick inline hunk staging/preview
- Diffview for detailed side-by-side comparison

### UI Core (5)
- `dashboard-nvim` - Start screen with "BEANS" header
- `lualine.nvim` - Statusline
- `nvim-notify` - Notifications
- `which-key.nvim` - Keybinding hints (minimal, curated)
- `indent-blankline.nvim` - Indent guides

### UI Enhancements (5)
- `neoscroll.nvim` - Smooth scrolling
- `smear-cursor.nvim` - Cursor animation
- `nvim-scrollbar` - Scrollbar with diagnostics
- `nvim-ufo` - Better folding
- `highlight-undo.nvim` - Flash on undo

### File Management (2)
- `neo-tree.nvim` - File explorer (auto-open on directory)
- `persistence.nvim` - Session management

### Editing (4)
- `nvim-autopairs` - Auto-close brackets
- `nvim-surround` - Surrounding operations
- `Comment.nvim` - Commenting (gcc, gc)
- `todo-comments.nvim` - Highlight TODOs

### Utilities (6)
- `trouble.nvim` - Diagnostics viewer
- `undotree` - Undo history tree
- `tmux-navigator` - Tmux integration
- `obsidian.nvim` - Obsidian vault integration
- `markdown-preview.nvim` - Markdown preview in browser
- `vim-be-good` - Vim training game

### Screenshots (1)
- `codesnap.nvim` - Code screenshots

### Colorschemes (8)
- `catppuccin` - Default (mocha), includes latte (single light theme)
- `tokyonight` - night, storm, moon variants
- `gruvbox` - dark variant
- `rose-pine` - main, moon variants
- `nord` - Nord theme
- `dracula` - Dracula theme
- `kanagawa` - wave, dragon variants
- `onedark` - OneDark theme

**Theme Configuration:**
- Default: catppuccin-mocha
- Switcher: `<leader>ft` (telescope theme picker with live preview)
- Persistence: Selected theme saved across sessions

---

## Keybinding Organization

### Philosophy
- Only user-defined keybindings show in which-key
- Organized into clear leader groups
- Plugins work with defaults, but which-key only shows explicit mappings

### Leader Key Groups

#### `<leader>f` - Find (Telescope)
- `ff` → Find files
- `fg` → Live grep
- `fb` → Buffers
- `fr` → Recent files
- `fp` → Projects
- `fz` → Z directories
- `fc` → Config files
- `ft` → Color themes
- `fh` → Help tags
- `fk` → Keymaps

#### `<leader>g` - Git
- `gg` → Lazygit
- `gb` → Git blame line
- `gd` → Diffview
- `gh` → Preview hunk
- `gs` → Stage hunk
- `gu` → Undo stage hunk
- `gr` → Reset hunk

#### `<leader>b` - Buffers
- `bn` → New buffer
- `bd` → Delete buffer
- `bD` → Delete buffer (force)
- `bo` → Delete other buffers
- `bj` → Next buffer
- `bk` → Previous buffer
- `bb` → List buffers

#### `<leader>w` - Windows
- `wv` → Split vertical
- `ws` → Split horizontal
- `wc` → Close window
- `wo` → Close other windows
- `wh/j/k/l` → Navigate windows
- `w=` → Equal size
- `wm` → Maximize toggle

#### `<leader>c` - Code (LSP)
- `ca` → Code action
- `cr` → Rename
- `cf` → Format
- `cd` → Definitions
- `cR` → References
- `ci` → Implementations
- `ct` → Type definitions

#### `<leader>x` - Diagnostics/Trouble
- `xx` → Toggle trouble
- `xw` → Workspace diagnostics
- `xd` → Document diagnostics
- `xq` → Quickfix
- `xl` → Location list

#### `<leader>u` - UI Toggles
- `ue` → Toggle neo-tree
- `uu` → Toggle undotree
- `ut` → Toggle treesitter
- `un` → Toggle line numbers
- `ur` → Toggle relative numbers
- `uw` → Toggle wrap
- `us` → Toggle spell
- `ui` → Toggle indent guides
- `uc` → Toggle conceal

#### `<leader>s` - Search/Session
- `ss` → Save session
- `sr` → Restore session
- `st` → Search TODOs
- `sw` → Search word under cursor
- `sR` → Search and replace

### Essential Non-Leader Bindings
- `<C-s>` → Save file
- `<C-n>` → Toggle neo-tree
- `<C-h/j/k/l>` → Tmux/window navigation
- `[d` / `]d` → Previous/next diagnostic
- `[b` / `]b` → Previous/next buffer
- `[h` / `]h` → Previous/next git hunk
- `[t` / `]t` → Previous/next todo
- `<Esc><Esc>` → Clear search highlight
- `J` / `K` → Move line down/up (visual mode)
- `<` / `>` → Indent/dedent (visual mode)
- `gcc` → Comment line
- `gc` → Comment motion
- `ys/cs/ds` → Surround operations
- `gd/gr/K` → LSP goto definition/references/hover

---

## Dashboard Configuration

### Dashboard-nvim Setup
```
[BEANS ASCII Art Header]

Actions:
  Find File (f)
  New File (n)
  Recent Files (r)
  Find Text (g)
  Projects (p)
  Config (c)
  Restore Session (s)
  Lazy (l)
  Quit (q)

[Footer: Plugin count + startup time]
```

**Features:**
- Clean design (no git status widget)
- Use exact "BEANS" header from current config
- Lazy plugin manager integration

---

## Special Configurations

### Obsidian Integration
- Vault path: `/Users/justincordova/Library/Mobile Documents/iCloud~md~obsidian/Documents/obi`
- Daily notes, templates, note linking
- Telescope integration
- Follow links with `gf`

### Markdown Rendering
- Handle both `.md` and `.MD` extensions
- Inline preview with render-markdown.nvim
- Browser preview with markdown-preview.nvim

### Auto-Save Configuration
- Timer: 2000ms (2 seconds) after idle
- Focus-lost: Save when switching buffers/windows
- Format on save: Enabled by default

### Neo-tree Behavior
- Auto-open when opening directories
- Show hidden files by default
- Git status integration

### Persistent Undo
- Undo history saved across sessions
- Accessible via undotree

### Theme Persistence
- Selected colorscheme saved and restored
- Default: catppuccin-mocha

---

## Implementation Plan

### Phase 1: Backup & Foundation
1. Git commit current config
2. Create new `init.lua` (kickstart structure)
3. Set up `custom/` directory (options, keymaps, autocmds, utils)
4. Bootstrap lazy.nvim (no LazyVim dependency)

### Phase 2: Core Plugins
1. Colorschemes (catppuccin + all variants)
2. Treesitter (foundation for other plugins)
3. LSP + Mason + blink.cmp
4. Telescope + extensions
5. Conform + nvim-lint

### Phase 3: UI & Navigation
1. Dashboard, lualine, nvim-notify, which-key
2. Neo-tree, persistence
3. UI enhancements (neoscroll, smear-cursor, scrollbar, ufo, highlight-undo, indent-blankline)

### Phase 4: Git & Editing
1. Lazygit, gitsigns, diffview
2. Autopairs, surround, Comment.nvim
3. Todo-comments, trouble

### Phase 5: Special Utilities
1. Undotree, tmux-navigator
2. Obsidian, markdown-preview
3. Codesnap, vim-be-good

### Phase 6: Testing & Refinement
1. Test all keybindings
2. Verify LSP servers install
3. Check theme switcher
4. Ensure error-free loading

---

## Verification Checklist

After implementation, verify:
- [ ] Neovim starts without errors
- [ ] Dashboard shows "BEANS" header correctly
- [ ] All keybindings work as expected
- [ ] LSP servers install and work
- [ ] Theme switcher shows all themes with preview
- [ ] Git integration (lazygit, gitsigns, diffview) works
- [ ] Auto-save triggers correctly
- [ ] Format on save works for all filetypes
- [ ] Telescope extensions load correctly
- [ ] Markdown renders both .md and .MD
- [ ] Obsidian vault integration works
- [ ] Neo-tree opens on directory launch
- [ ] Session persistence works
- [ ] All UI enhancements function properly

---

## Notes

- Look up official GitHub docs for each plugin during implementation
- Ask about configuration choices when multiple options exist
- Remove codediff plugin (user requested)
- Keep config clean and minimal - only explicit configuration
- No rainbow brackets in treesitter
- C# parser for .NET development
