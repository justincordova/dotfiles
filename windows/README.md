# Windows setup

Native Windows + PowerShell 7. No WSL, no Stow.

`bootstrap.ps1` replaces what Homebrew + Stow + `agent/install.sh` do on macOS.
`profile.ps1` is the port of `zsh/.zshrc`.

## What maps to what

| macOS                          | Windows                                        |
| ------------------------------ | ---------------------------------------------- |
| `~/.zshrc`                     | `profile.ps1` -> `$PROFILE.CurrentUserAllHosts` |
| Homebrew                       | winget (+ npm for OpenCode, direct dl for rtk)  |
| GNU Stow                       | `bootstrap.ps1 -Only link`                      |
| `~/.config/nvim`               | `%LOCALAPPDATA%\nvim`                           |
| `~/.config/starship.toml`      | same path, via `$env:STARSHIP_CONFIG`           |
| Ghostty                        | WezTerm / Windows Terminal                      |
| tmux                           | *(dropped — no native Windows build)*           |
| `credential.helper=osxkeychain`| `credential.helper=manager`                     |
| `core.autocrlf=input`          | `core.autocrlf=true`                            |

## Prerequisites

1. **Developer Mode on** — Settings > System > For developers > Developer Mode.
   Required for symlinks without elevation. `bootstrap.ps1` refuses to link without it.
2. **PowerShell 7** — `winget install Microsoft.PowerShell`. Run everything from `pwsh`,
   not the built-in Windows PowerShell 5.1.
3. **An SSH key on GitHub** — the repos are cloned over SSH.
   `ssh-keygen -t ed25519 -C "you@example.com"; gh auth login`

## Run

```powershell
git clone git@github.com:justincordova/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles\windows

.\bootstrap.ps1 -WhatIf     # dry run first
.\bootstrap.ps1
```

Restart the terminal between phases where noted — winget changes `PATH` and the
current session won't see it.

Phases are independent and re-runnable:

```powershell
.\bootstrap.ps1 -Only packages   # winget
.\bootstrap.ps1 -Only node       # node, opencode, claude, rtk
.\bootstrap.ps1 -Only link       # clone repos + symlink configs
.\bootstrap.ps1 -Only agents     # ~/agent install + opencode config
.\bootstrap.ps1 -Only nvim       # lazy.nvim sync
```

## Manual steps afterward

These can't be scripted.

1. `rtk init -g` — installs the native binary hook. This replaces the macOS
   `~/.claude/hooks/rtk-rewrite.sh`; do **not** copy that script over.
2. `gh auth login`
3. `claude` -> `/login`, then install plugins:
   ```
   /plugin marketplace add jarrodwatts/claude-hud
   /plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill
   /plugin install claude-hud@claude-hud
   /plugin install typescript-lsp@claude-plugins-official
   /plugin install gopls-lsp@claude-plugins-official
   /plugin install pyright-lsp@claude-plugins-official
   /plugin install clangd-lsp@claude-plugins-official
   /plugin install lua-lsp@claude-plugins-official
   /plugin install context7@claude-plugins-official
   /plugin install code-review@claude-plugins-official
   /plugin install commit-commands@claude-plugins-official
   /plugin install claude-md-management@claude-plugins-official
   /plugin install ui-ux-pro-max@ui-ux-pro-max-skill
   ```
4. `Update-ClaudeHud` — pins the statusline to a direct `bun.exe` path.
   The setup command generates a `powershell -Command` wrapper that spawns a
   visible console window on every ~300ms refresh
   ([claude-hud#121](https://github.com/jarrodwatts/claude-hud/issues/121)).
   Re-run this after any claude-hud update.
5. `opencode` -> `/connect`
6. Set the terminal font to **JetBrainsMono Nerd Font**, or the Starship prompt
   and Neovim devicons render as tofu.
7. Fill in `~/.gitconfig.local`.

## Secrets

API keys are **not** in this repo. `bootstrap.ps1` writes `~/.opencode/opencode.json`
with `{env:VAR}` placeholders that OpenCode resolves at runtime. Set them once:

```powershell
[Environment]::SetEnvironmentVariable('CONTEXT7_API_KEY',  '<key>', 'User')
[Environment]::SetEnvironmentVariable('FIRECRAWL_API_KEY', '<key>', 'User')
```

> The macOS machine currently has these keys inlined in
> `~/.claude/settings.json` and `~/.opencode/opencode.json`. Those files are
> untracked, so nothing leaked — but rotate them if that ever changes.

## Known gaps vs. macOS

- **tmux** — no native build. The `zsh` auto-start block and `tmux/` package are
  skipped entirely. Use WezTerm panes or Windows Terminal tabs.
- **`vim-tmux-navigator`** — installs but the pane-navigation half is inert.
- **Treesitter** — needs a C compiler. `bootstrap.ps1` installs LLVM and zig; if
  `:TSUpdate` fails, `:checkhealth nvim-treesitter`.
- **`telescope-fzf-native`** — its `build = 'make'` is guarded by
  `vim.fn.executable 'make'`, so it silently drops. Telescope falls back to the
  Lua sorter. Install `make` via winget (`GnuWin32.Make`) if you want the native one.
- **`obsidian.nvim`** — gated to macOS via `cond`, so it never loads here. The
  `:Scratch` fleeting-note commands in `config/scratch.lua` target the same vault
  and will warn rather than write. Set `$env:OBSIDIAN_VAULT` and drop the `cond`
  if you ever want it.
- **`cot`, `duti`, `spicetify`, `asciiquarium`, `pipes-sh`, `cbonsai`** — macOS-only
  or unavailable; dropped.
