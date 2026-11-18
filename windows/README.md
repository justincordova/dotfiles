# Windows setup

Native Windows + PowerShell 7. No WSL, no Stow.

`bootstrap.ps1` replaces what Homebrew + Stow + `agent/install.sh` do on macOS.
`profile.ps1` is the port of `zsh/.zshrc`.

## What maps to what

| macOS                          | Windows                                         |
| ------------------------------ | ----------------------------------------------- |
| `~/.zshrc`, `~/.zshenv`        | `profile.ps1`, loaded from `$PROFILE.CurrentUserAllHosts` (a one-line loader, not a symlink: Documents is often in OneDrive) |
| Homebrew                       | winget (+ npm, + GitHub releases for rtk, diffnav, supabase) |
| GNU Stow                       | `bootstrap.ps1 -Only link`                      |
| `~/.config/nvim`               | `%LOCALAPPDATA%\nvim`                           |
| `~/.config/starship.toml`      | same path, via `$env:STARSHIP_CONFIG`           |
| `~/.config/opencode`           | same path (`C:\Users\you\.config\opencode`)     |
| `~/.config/gh-dash`            | same path                                       |
| Ghostty                        | Windows Terminal                                |
| tmux                           | *(none — no native build; use Terminal tabs/panes)* |
| oh-my-zsh `z`                  | zoxide                                          |
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

Everything already installed is skipped, so re-running is safe — including on
a machine that's already set up. A package counts as installed if winget knows
it **or** its command is already on PATH (Store, scoop or manual installs).

Restart the terminal after `packages` — winget changes `PATH` and the current
session only partly picks it up.

Phases are independent and re-runnable:

```powershell
.\bootstrap.ps1 -Only packages   # winget: shell, git tools, CLI tools, Tailscale, Go, build tools
.\bootstrap.ps1 -Only node       # node (nvm), pnpm, agent-browser + Chrome, rtk, claude
.\bootstrap.ps1 -Only opencode   # OpenCode 2 -- opt-in, see below
.\bootstrap.ps1 -Only link       # clone repos + symlink configs
.\bootstrap.ps1 -Only tools      # gh-dash + diffnav
.\bootstrap.ps1 -Only db         # psql (client only), sqlcmd, supabase
.\bootstrap.ps1 -Only docker     # Docker Desktop, lazydocker
.\bootstrap.ps1 -Only langs      # Java 21, .NET 10 SDK, Rust
.\bootstrap.ps1 -Only agents     # ~/agent, opencode plugins + rtk hook, secrets template
.\bootstrap.ps1 -Only nvim       # lazy.nvim restore from lazy-lock.json
.\bootstrap.ps1 -Only ssh        # OpenSSH server -- needs an elevated pwsh
```

`-Skip` excludes winget IDs. Packages install in list order, so a single hanging
installer otherwise blocks everything after it:

```powershell
.\bootstrap.ps1 -Skip Docker.DockerDesktop,Python.Python.3.13
```

## OpenCode

Same setup as macOS and Linux: OpenCode 2 with the tracked
`opencode/.config/opencode/` linked into `~\.config\opencode` —
`opencode.json` (plugins, MCP servers, `/mystatus`), `tui.json`, `themes`,
and `v2-plugins` (the Anthropic OAuth plugin, quotas, `rtk.ts`). The
`agents` phase installs the plugins' dependencies (`npm ci`), links `rtk.ts`
to `~\.opencode\plugins\rtk.ts`, and seeds `cli.json` as a copy (OpenCode
rewrites it, which would break a symlink).

**Installing OpenCode is opt-in** — the default run only checks it and tells
you if it's missing or still v1. To install:

```powershell
.\bootstrap.ps1 -Only opencode
# or by hand:
npm install -g @opencode/cli
```

Use `@opencode/cli`. `opencode-ai` and the `opencode.ai/install` script are
still OpenCode 1, which can't load the v2 plugins. If `opencode --version`
shows 1.x, remove it first (`npm uninstall -g opencode-ai`).

**Logging in:** the Anthropic login is per machine. Run `opencode` ->
`/connect` -> Anthropic here rather than copying tokens from the Mac:
Anthropic rotates the refresh token on every refresh, so two machines sharing
one would keep logging each other out.

**On a machine that already had OpenCode:** existing files in
`~\.config\opencode` that the links replace are kept as `*.bak-<timestamp>`.
An old `~\.opencode\opencode.json` written by earlier versions of this script
(with `opencode-claude-auth`, which conflicts with the Anthropic plugin) is
moved aside the same way.

## Secrets

API keys are **not** in this repo. `opencode.json` references them as
`{env:CONTEXT7_API_KEY}` / `{env:FIRECRAWL_API_KEY}`. The `agents` phase
creates `~\.config\opencode\secrets.env` — the same file macOS and Linux use —
and `profile.ps1` loads it into every shell. Fill it in:

```
export CONTEXT7_API_KEY=...
export FIRECRAWL_API_KEY=...
```

The OpenCode background service inherits the environment of the shell that
starts it, so start `opencode` from pwsh. User-level environment variables
(`[Environment]::SetEnvironmentVariable(..., 'User')`) also still work and are
not overridden by empty lines in the file.

## SSH server

`-Only ssh` (from an elevated pwsh) installs OpenSSH Server, starts it on boot,
opens port 22 in the firewall, and makes pwsh the login shell.

Password login stays on until a key is authorized. For an account in the
Administrators group, Windows reads keys from
`C:\ProgramData\ssh\administrators_authorized_keys`, **not**
`~\.ssh\authorized_keys`, and that file must be locked down:

```powershell
# elevated, after pasting your public key into the file
icacls "$env:ProgramData\ssh\administrators_authorized_keys" /inheritance:r /grant Administrators:F /grant SYSTEM:F
.\bootstrap.ps1 -Only ssh      # now turns password login off
```

There's no tmux here, so a dropped SSH session ends whatever was running in
the foreground. Long-running services (jobvr) belong in Docker.

## Manual steps afterward

1. Restart the terminal.
2. `gh auth login`, if you haven't.
3. Fill in `~\.config\opencode\secrets.env`.
4. `opencode` -> `/connect` Anthropic (and Google), then `/mcps` to sign in to
   supabase and atlassian.
5. Set the Windows Terminal font to **JetBrainsMono Nerd Font**, or the Starship
   prompt and Neovim devicons render as tofu.
6. `tailscale up`, if the machine should be on the tailnet.
7. Docker Desktop: reboot if the installer asks, start it once, accept the terms.
8. Fill in `~/.gitconfig.local` if anything machine-specific is needed.

The script ends with a **Needs you** list of whatever of this applies.

**Claude Code** is still installed in case it's needed. If you use it:
`claude` -> `/login`, add the plugins below, then `Update-ClaudeHud` (pins the
statusline to `bun.exe`; the generated `powershell -Command` wrapper flashes a
console window every refresh,
[claude-hud#121](https://github.com/jarrodwatts/claude-hud/issues/121)).

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

## Known gaps vs. macOS

- **tmux** — no native build. The `zsh` auto-start block and `tmux/` package
  don't apply. Use Windows Terminal tabs and panes.
- **`vim-tmux-navigator`** — installs but the pane-navigation half is inert.
- **redis-cli** — no maintained native build. Use the container's:
  `docker exec -it <redis-container> redis-cli`.
- **psql** comes from EDB's installer with the server deselected; its `bin` is
  not on the system PATH, so `profile.ps1` adds it.
- **Rust** — `rustfmt` and rust-analyzer work, but building binaries needs
  Visual Studio Build Tools ("Desktop development with C++"), which is not
  installed (several GB).
- **Treesitter** — needs a C compiler. LLVM (clang) is installed for this; if
  `:TSUpdate` fails, run `:checkhealth nvim-treesitter`.
- **`obsidian.nvim`** — gated to macOS via `cond`, so it never loads here. The
  `:Scratch` fleeting-note commands in `config/scratch.lua` target the same vault
  and will warn rather than write. Set `$env:OBSIDIAN_VAULT` and drop the `cond`
  if you ever want it.
- **Ollama, FFmpeg, ImageMagick, Pandoc, zig** — installed on macOS,
  deliberately skipped here.
- **`cot`, `duti`, `spicetify`, `asciiquarium`, `pipes-sh`, `cbonsai`** — macOS-only
  or unavailable; dropped.
