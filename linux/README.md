# Linux setup

Linux dev box, driven over SSH from the Windows machine. This is where the web
work runs; Windows stays for Windows-native projects.

| Distro | Status |
| --- | --- |
| Ubuntu 22.04+ | Tested (24.04) |
| Debian 12+ | Tested (13) |
| Fedora 41+ | Tested (45) |
| Mint, Pop!_OS, other Ubuntu/Debian derivatives | Should work, untested — repos are mapped to the base release |
| Arch, openSUSE, RHEL/Alma/Rocky, … | Not supported; the script exits |

Only the package steps differ (`apt` vs `dnf`). Everything fetched upstream —
GitHub releases, nvm, Go, rustup, npm, stow, the OpenCode setup — is identical.

`bootstrap.sh` is the Linux counterpart to `windows/bootstrap.ps1`.
Unlike Windows, the shared Stow packages (`zsh`, `nvim`, `starship`, `git`,
`shell`, `opencode`) apply directly — Stow works here. `tmux` is intentionally
not installed or stowed on this box.

## Prerequisites

1. **An SSH key on GitHub**, since the repos clone over SSH:
   ```sh
   ssh-keygen -t ed25519 -C "you@example.com"
   cat ~/.ssh/id_ed25519.pub    # add at github.com/settings/keys
   ```
2. **sudo access.** The script installs system packages and adds you to `docker`.

## Run

```sh
sudo apt update && sudo apt install -y git    # Ubuntu/Debian
sudo dnf install -y git                       # Fedora

git clone git@github.com:justincordova/dotfiles.git ~/dotfiles
cd ~/dotfiles/linux

DRY_RUN=1 ./bootstrap.sh    # see what it would do
./bootstrap.sh
```

Phases are re-runnable, and run in this order when you pass none:

```sh
./bootstrap.sh packages    # base packages (apt or dnf), gh, eza
./bootstrap.sh ssh         # openssh-server; key-only login once a key is present
./bootstrap.sh link        # clone repos + stow dotfiles
./bootstrap.sh tools       # oh-my-zsh, starship, lazygit, lazydocker, delta, tree-sitter, go
./bootstrap.sh node        # nvm + node, bun, pnpm, opencode 2, agent-browser, claude, rtk
./bootstrap.sh docker      # docker-ce + compose plugin
./bootstrap.sh db          # psql, redis-cli, sqlcmd, supabase
./bootstrap.sh nvim        # current Neovim + plugins pinned by lazy-lock.json
./bootstrap.sh agents      # ~/agent skills, opencode plugins, secrets template
```

`agents` needs npm, so run `node` first if you're running phases one at a time.

One phase is **opt-in** and only runs when named:

```sh
./bootstrap.sh langs       # Java 21 (25 on Fedora), .NET 10 SDK, Rust -- for nvim's jdtls, OmniSharp, rustfmt
```

## SSH access

Ubuntu Desktop ships without an SSH server and Fedora Workstation leaves its
disabled; the `ssh` phase installs and enables it, and on Fedora also allows
`ssh` through firewalld. It only switches to **key-only login** once
`~/.ssh/authorized_keys` exists, so the first run can't lock you out. From
Windows:

```powershell
type $HOME\.ssh\id_ed25519.pub | ssh you@linux-box "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

Then on the box, `./bootstrap.sh ssh` to turn off password login. The setting
lives in `/etc/ssh/sshd_config.d/10-dotfiles.conf`; delete it and
`sudo systemctl reload ssh` to undo.

The SSH tunnels below only work where Windows can reach the box (same LAN). For
access from elsewhere, put both machines on [Tailscale](https://tailscale.com)
rather than opening a port on the router.

**Windows Terminal needs a Nerd Font** (e.g. *JetBrainsMono Nerd Font*) for the
icons in Starship, Neovim and eza. The terminal on your side draws them, not the
Linux box.

> `link` **must** precede `tools`. oh-my-zsh's `KEEP_ZSHRC` only stops it
> replacing an `~/.zshrc` that already exists; with none present it writes its
> own template, which then blocks `stow zsh` and leaves you on the template
> instead of your real config.

## After

```sh
chsh -s $(command -v zsh)   # then log out and back in
rtk init -g                 # Claude Code hook only -- see below
gh auth login
```

- Fill in `~/.config/opencode/secrets.env` (untracked, `chmod 600`, sourced by
  `~/.zshenv` so the OpenCode background service sees it too):
  ```sh
  export CONTEXT7_API_KEY=...
  export FIRECRAWL_API_KEY=...
  ```
- `claude` -> `/login`
- `opencode` -> `/connect` for Anthropic and Google, then `/mcps` to sign in to
  supabase and atlassian (OAuth, no keys)

Git identity is tracked in `git/.gitconfig`; `~/.gitconfig.local` only holds
line endings and the credential helper.

## OpenCode

This box runs **OpenCode 2**, installed from npm as `@opencode/cli`. Don't
install `opencode-ai` or use the `opencode.ai/install` script: both are still
OpenCode 1, which can't load the plugins below.

Everything lives in the tracked `opencode/.config/opencode/`:

| Piece | What it is |
| --- | --- |
| `opencode.json` | Plugins, MCP servers (context7, firecrawl, supabase, atlassian), `/mystatus` |
| `v2-plugins/anthropic` | Claude Pro/Max OAuth (own grant, so it doesn't fight `claude`) |
| `v2-plugins/quotas` | The `mystatus` quota tool |
| `v2-plugins/rtk.ts` | RTK shell hook, linked into `~/.opencode/plugins/` |

`v2-plugins/` imports from its own `node_modules`, which the `agents` phase
installs with `npm ci --ignore-scripts`. After pulling plugin changes, re-run
`./bootstrap.sh agents`.

> Don't run `rtk init --opencode`. It writes an OpenCode 1 plugin that would
> shadow the v2 `rtk.ts` above.

`cli.json` (theme, sidebar) is copied from `linux/opencode-cli.json` rather than
stowed, because OpenCode rewrites that file in place and would replace the
symlink.

**Log out and back in after the docker phase** — group membership only applies to
new login sessions. Until then `docker` needs `sudo`.

## Reaching the dev server from Windows

Forward the port over SSH rather than exposing it:

```powershell
ssh -L 3000:localhost:3000 you@linux-box
```

Then open `http://localhost:3000` in the Windows browser. Nothing is exposed to
the network and no firewall changes are needed (Windows still has to reach the
box over SSH -- see [SSH access](#ssh-access)). Keep that
SSH session open — closing it drops the tunnel.

Multiple ports at once:

```powershell
ssh -L 3000:localhost:3000 -L 5432:localhost:5432 -L 8080:localhost:8080 you@linux-box
```

Make it permanent in `~/.ssh/config` on Windows so plain `ssh dev` carries the
tunnels:

```
Host dev
    HostName 192.168.1.50
    User you
    LocalForward 3000 localhost:3000
    LocalForward 5432 localhost:5432
    ServerAliveInterval 60
```

> Some dev servers bind to `127.0.0.1` and others to `0.0.0.0`. With SSH
> forwarding either works, because the tunnel terminates on the box itself. If a
> forwarded port refuses to connect, check the server is actually listening:
> `ss -tlnp | grep 3000`.

## Database clients

No database servers are installed — only clients, since the DB lives on the
company server.

| Tool | Connects to | Example |
| --- | --- | --- |
| `psql` | PostgreSQL / Supabase | `psql -h HOST -U USER -d DB` |
| `sqlcmd` | Microsoft SQL Server | `sqlcmd -S HOST -U USER -d DB -C` |
| `redis-cli` | Redis | `redis-cli -h HOST` |
| `supabase` | Supabase projects | `supabase link --project-ref REF` |

`sqlcmd` from `mssql-tools18` **verifies TLS by default**. Company servers
usually run self-signed certs, so you'll need `-C` (trust the server cert) or
you'll get a certificate-chain error. Add `-N` to force encryption.

Quick reachability check before blaming credentials:

```sh
nc -vz HOST 1433    # SQL Server
nc -vz HOST 5432    # PostgreSQL
```

Never put credentials in the shell — they land in `~/.zsh_history`. Use a
`~/.pgpass` (chmod 600) for psql, or read the password interactively by omitting
`-P` for sqlcmd.

## Differences from macOS

- **No Homebrew.** apt/dnf plus upstream installers. `.zshrc` probes for `brew` and
  skips it when absent, so the same file works on all three machines.
- **`bat` and `fd`** are `batcat` and `fdfind` on Debian. The script symlinks the
  real names into `~/.local/bin`.
- **OpenCode from npm** (`@opencode/cli`), not Homebrew.
- **Git editor.** `.gitconfig` uses `code --wait`; when `code` isn't on PATH
  (plain SSH), `.zshrc` sets `GIT_EDITOR=nvim` instead.
- **Neovim from GitHub releases**, not apt — apt ships a version too old for
  `blink.cmp` and the rest of the config.
- **No tmux.** Not installed, and the `tmux` package isn't stowed. `.zshrc` only
  auto-starts tmux under Ghostty, so nothing fires here.

  Without it, **anything running in the foreground dies when SSH drops.** For a
  long-running dev server, use one of:

  ```sh
  # detach a one-off process
  nohup npm run dev > dev.log 2>&1 &

  # or run it in Docker, which survives disconnects by design
  docker compose up -d
  ```

  If reconnect-and-resume becomes a recurring need, `apt install tmux` and add
  `tmux` back to the stow list in `bootstrap.sh` — the config is already
  cross-platform.
- **obsidian.nvim** is gated to macOS and won't load.
- **Go from go.dev** into `/usr/local/go`, not the distro (too old for current gopls).
- **Fedora specifics.** `gh` and `eza` come from Fedora's own repos;
  `redis-cli` is Valkey's compat package (Fedora replaced Redis with Valkey);
  `sqlcmd` uses Microsoft's RHEL 9 repo, since there is no Fedora one; the
  Docker daemon is enabled explicitly because Fedora doesn't start it on install.
- **Directory jumping** is oh-my-zsh's `z` plugin on both machines; zoxide isn't
  installed.
