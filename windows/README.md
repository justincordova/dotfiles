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
2. **Bootstrap the bootstrapper.** The script clones over SSH, so git, pwsh, and gh
   have to exist before it runs. From the stock Windows PowerShell:

   ```powershell
   winget install Git.Git Microsoft.PowerShell GitHub.cli
   ```

   Then close it and open **pwsh** for everything below — not Windows PowerShell 5.1.
3. **Auth to GitHub**, which also generates and uploads an SSH key:

   ```powershell
   gh auth login          # choose SSH, let it create the key
   ```

## Run

```powershell
git clone git@github.com:justincordova/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles\windows

.\bootstrap.ps1 -WhatIf     # dry run first
.\bootstrap.ps1
```

The three packages above are in the winget list too, so re-installing them is a
no-op — the script skips anything already present.

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

`-Skip` excludes winget IDs. Packages install in list order, so a single hanging
installer otherwise blocks everything after it:

```powershell
.\bootstrap.ps1 -Only packages -Skip Python.Python.3.13
```

## Manual steps afterward

These can't be scripted. **Run them in this order** — each depends on the last.

1. `.\bootstrap.ps1 -Only link` then `-Only agents`, if you haven't. The agents
   phase is what creates `~\.claude\` and populates it from the `agent` repo.
2. `rtk init -g` — installs the native binary hook. This replaces the macOS
   `~/.claude/hooks/rtk-rewrite.sh`; do **not** copy that script over.
   It writes into `~\.claude\` and fails with `os error 3` if step 1 was skipped.
3. `gh auth login`
4. `claude` -> `/login`, then install plugins:
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
5. `Update-ClaudeHud` — pins the statusline to a direct `bun.exe` path.
   The setup command generates a `powershell -Command` wrapper that spawns a
   visible console window on every ~300ms refresh
   ([claude-hud#121](https://github.com/jarrodwatts/claude-hud/issues/121)).
   Re-run this after any claude-hud update.
6. `opencode` -> `/connect`
7. Set the terminal font to **JetBrainsMono Nerd Font**, or the Starship prompt
   and Neovim devicons render as tofu.
8. Fill in `~/.gitconfig.local`.

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
- **Treesitter** — needs a C compiler. `bootstrap.ps1` installs LLVM (clang) for
  this; if `:TSUpdate` fails, run `:checkhealth nvim-treesitter`.
- **Go, zig, Ollama, FFmpeg, ImageMagick, Pandoc** — installed on macOS,
  deliberately skipped here. `$env:GOPATH` is still set in `profile.ps1` to keep
  parity with `.zshrc`; it points at a directory that won't exist, which is
  harmless. Add the packages back to `$WingetPackages` if that changes.
- **`telescope-fzf-native`** — its `build = 'make'` is guarded by
  `vim.fn.executable 'make'`, so it silently drops. Telescope falls back to the
  Lua sorter. Install `make` via winget (`GnuWin32.Make`) if you want the native one.
- **`obsidian.nvim`** — gated to macOS via `cond`, so it never loads here. The
  `:Scratch` fleeting-note commands in `config/scratch.lua` target the same vault
  and will warn rather than write. Set `$env:OBSIDIAN_VAULT` and drop the `cond`
  if you ever want it.
- **`cot`, `duti`, `spicetify`, `asciiquarium`, `pipes-sh`, `cbonsai`** — macOS-only
  or unavailable; dropped.
