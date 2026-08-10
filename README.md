# dotfiles

Personal dotfiles for macOS and Windows.

- **macOS** — [GNU Stow](https://www.gnu.org/software/stow/) symlinks each package into `$HOME`.
- **Windows** — [`windows/bootstrap.ps1`](windows/README.md) provisions the machine and
  symlinks the shared configs (`nvim/`, `starship/`, `git/`) into their Windows locations.

`nvim/`, `starship/`, and `git/` are shared by both platforms. Anything
platform-specific (credential helper, line endings, identity) lives in the
untracked `~/.gitconfig.local`.

## Layout

Each top-level directory is a Stow package whose internal structure mirrors `$HOME`.
Stowing a package symlinks its contents into the right place.

| Package     | Symlinks to                  | Notes                                  |
| ----------- | ---------------------------- | -------------------------------------- |
| `bash/`     | `~/.bashrc`                  | Bash shell config (Starship prompt)    |
| `git/`      | `~/.gitconfig`, global ignore | Identity lives in `~/.gitconfig.local` |
| `nvim/`     | `~/.config/nvim/`            | lazy.nvim-based Neovim config          |
| `opencode/` | `~/.config/opencode/`        | Theme, agents, commands, skills        |
| `starship/` | `~/.config/starship.toml`    | Cross-shell prompt                     |
| `tmux/`     | `~/.tmux.conf`, theme        | TPM + theme switcher                   |
| `vim/`      | `~/.vimrc`                   | Minimal Vim fallback                   |
| `zsh/`      | `~/.zshrc`                   | Primary shell (Starship prompt)        |
| `shell/`    | `~/.shell_aliases`           | Aliases shared by bash + zsh           |

`scripts/` and `windows/` are **not** Stow packages. `scripts/` is invoked by
absolute path at runtime; `windows/` is consumed by `bootstrap.ps1`. Do not run
`stow */` — it selects every directory regardless of `.stow-local-ignore`, which
only filters *within* a package. Name the packages explicitly.

## Setup (macOS)

```sh
git clone git@github.com:justincordova/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh bash git nvim opencode starship tmux vim shell
```

To remove a package's symlinks: `stow -D <package>`.

API keys are **not** tracked. `~/.opencode/opencode.json` holds the MCP server
secrets and stays untracked on every machine.

## Setup (Windows)

See [`windows/README.md`](windows/README.md).

```powershell
irm https://raw.githubusercontent.com/justincordova/dotfiles/main/windows/bootstrap.ps1 | iex
```

## Machine-local config

Machine-specific git config is **not** tracked — identity *and* anything
platform-dependent. Create `~/.gitconfig.local`:

```ini
[user]
	name = Your Name
	email = you@example.com
[core]
	autocrlf = input      ; macOS/Linux — use `true` on Windows
[credential]
	helper = osxkeychain  ; macOS — use `manager` on Windows
```

The tracked `~/.gitconfig` pulls it in via `[include]` at the top of the file,
so **do not** re-declare these keys in the tracked config: later values win and
would clobber the per-machine ones.
