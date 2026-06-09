# dotfiles

Personal dotfiles for macOS, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Each top-level directory is a Stow package whose internal structure mirrors `$HOME`.
Stowing a package symlinks its contents into the right place.

| Package     | Symlinks to                  | Notes                                  |
| ----------- | ---------------------------- | -------------------------------------- |
| `bash/`     | `~/.bashrc`                  | Bash shell config (Starship prompt)    |
| `git/`      | `~/.gitconfig`, global ignore | Identity lives in `~/.gitconfig.local` |
| `nvim/`     | `~/.config/nvim/`            | lazy.nvim-based Neovim config          |
| `starship/` | `~/.config/starship.toml`    | Cross-shell prompt                     |
| `tmux/`     | `~/.tmux.conf`, theme        | TPM + theme switcher                   |
| `vim/`      | `~/.vimrc`                   | Minimal Vim fallback                   |
| `zsh/`      | `~/.zshrc`                   | Primary shell (Starship prompt)        |
| `shell/`    | `~/.shell_aliases`           | Aliases shared by bash + zsh           |

`scripts/` is intentionally **not** a Stow package (excluded via
`.stow-local-ignore`). Its scripts are invoked by absolute path at runtime.

## Setup

```sh
git clone <repo-url> ~/dotfiles
cd ~/dotfiles

# Stow individual packages
stow zsh bash git nvim starship tmux vim shell

# Or stow everything tracked (scripts/ and README are auto-ignored)
stow */
```

To remove a package's symlinks: `stow -D <package>`.

## Machine-local config

Machine-specific git identity is **not** tracked. Create `~/.gitconfig.local`:

```ini
[user]
	name = Your Name
	email = you@example.com
```

The tracked `~/.gitconfig` pulls it in via `[include]`.
