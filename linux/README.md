# Linux setup

Ubuntu/Debian dev box, driven over SSH from the Windows machine. This is where
the web work runs; Windows stays for Windows-native projects.

`bootstrap.sh` is the apt/upstream counterpart to `windows/bootstrap.ps1`.
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
sudo apt update && sudo apt install -y git
git clone git@github.com:justincordova/dotfiles.git ~/dotfiles
cd ~/dotfiles/linux

DRY_RUN=1 ./bootstrap.sh    # see what it would do
./bootstrap.sh
```

Phases are independent and re-runnable:

```sh
./bootstrap.sh packages    # apt, gh, eza
./bootstrap.sh tools       # oh-my-zsh, starship, zoxide, atuin, lazygit, delta
./bootstrap.sh node        # nvm + node, bun, opencode, claude, rtk
./bootstrap.sh docker      # docker-ce + compose plugin
./bootstrap.sh db          # psql, redis-cli, sqlcmd, supabase
./bootstrap.sh nvim        # current Neovim + lazy sync
./bootstrap.sh link        # clone repos + stow dotfiles
./bootstrap.sh agents      # ~/agent install + opencode config
```

## After

```sh
chsh -s $(command -v zsh)   # then log out and back in
rtk init -g
gh auth login
```

- `claude` -> `/login`
- `opencode` -> `/connect`
- Set your email in `~/.gitconfig.local`
- Put API keys in `~/.zshrc.local` (untracked):
  ```sh
  export CONTEXT7_API_KEY=...
  export FIRECRAWL_API_KEY=...
  ```

**Log out and back in after the docker phase** — group membership only applies to
new login sessions. Until then `docker` needs `sudo`.

## Reaching the dev server from Windows

Forward the port over SSH rather than exposing it:

```powershell
ssh -L 3000:localhost:3000 you@linux-box
```

Then open `http://localhost:3000` in the Windows browser. Nothing is exposed to
the network, it works on any Wi-Fi, and no firewall changes are needed. Keep that
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

- **No Homebrew.** apt plus upstream installers. `.zshrc` probes for `brew` and
  skips it when absent, so the same file works on all three machines.
- **`bat` and `fd`** are `batcat` and `fdfind` on Debian. The script symlinks the
  real names into `~/.local/bin`.
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
