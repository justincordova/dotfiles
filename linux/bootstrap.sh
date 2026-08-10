#!/usr/bin/env bash
#
# Provision an Ubuntu/Debian dev box to match the macOS setup.
# Idempotent -- safe to re-run. Phases can be run in isolation.
#
#   ./bootstrap.sh                  # everything
#   ./bootstrap.sh packages node    # only those phases
#   DRY_RUN=1 ./bootstrap.sh        # print apt/install actions, change nothing
#
# Phases: packages tools node docker db agents link nvim
#
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
AGENT_DIR="${AGENT_DIR:-$HOME/agent}"
DOTFILES_REPO="${DOTFILES_REPO:-git@github.com:justincordova/dotfiles.git}"
AGENT_REPO="${AGENT_REPO:-git@github.com:justincordova/agents.git}"
LOCAL_BIN="$HOME/.local/bin"

FAILED=()
PHASES=("$@")

# All logging goes to stderr. Several call sites look like
#   curl ... | run sudo tee FILE >/dev/null
# where the trailing redirect would otherwise swallow the log line too.
c_head() { printf '\n\033[1;36m%s\033[0m\n' "$*" >&2; }
c_good() { printf '  \033[0;32m%s\033[0m\n' "$*" >&2; }
c_warn() { printf '  \033[0;33m%s\033[0m\n' "$*" >&2; }
c_info() { printf '  \033[0;90m%s\033[0m\n' "$*" >&2; }
c_err()  { printf '  \033[0;31m%s\033[0m\n' "$*" >&2; }

phase() {
  [ ${#PHASES[@]} -eq 0 ] && return 0
  local p
  for p in "${PHASES[@]}"; do [ "$p" = "$1" ] && return 0; done
  return 1
}

have() { command -v "$1" >/dev/null 2>&1; }

run() {
  if [ -n "${DRY_RUN:-}" ]; then
    c_info "DRY: $*"
    # Several call sites are `curl ... | run sudo tee ...`. Without executing the
    # command nothing reads the pipe, so curl dies with "(23) Failure writing
    # output to destination" and set -e aborts the run. Drain stdin when piped.
    [ -t 0 ] || cat >/dev/null 2>&1 || true
    return 0
  fi
  "$@"
}

# Latest GitHub release asset URL matching a pattern.
gh_asset() {
  local repo="$1" pattern="$2"
  curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
    | grep -o "\"browser_download_url\": *\"[^\"]*${pattern}[^\"]*\"" \
    | head -1 | cut -d'"' -f4
}

# ------------------------------------------------------------------ preflight --

c_head 'Preflight'

if ! have apt-get; then
  echo "This script targets Ubuntu/Debian (apt). Aborting." >&2
  exit 1
fi

. /etc/os-release
DEB_ARCH=$(dpkg --print-architecture)   # amd64 | arm64
c_good "${PRETTY_NAME:-unknown}  ($DEB_ARCH)"

# Release assets name architectures inconsistently across projects.
case "$DEB_ARCH" in
  amd64) A_LAZYGIT=linux_x86_64; A_DELTA=x86_64-unknown-linux-gnu; A_NVIM=linux-x86_64 ;;
  arm64) A_LAZYGIT=linux_arm64;  A_DELTA=aarch64-unknown-linux-gnu; A_NVIM=linux-arm64 ;;
  *) echo "Unsupported architecture: $DEB_ARCH" >&2; exit 1 ;;
esac

if ! sudo -n true 2>/dev/null; then
  c_warn 'sudo will prompt for your password.'
fi

mkdir -p "$LOCAL_BIN"

# ------------------------------------------------------------------- packages --

APT_PACKAGES=(
  # shell
  zsh stow
  # build + fetch
  build-essential curl wget git unzip ca-certificates gnupg pkg-config
  # cli
  ripgrep fd-find bat jq fzf tree htop
  # clipboard bridge for CLI tools over X11 forwarding
  xclip
  # python
  python3 python3-pip python3-venv
  # sqlite headers so nvim's sqlite.lua has a clib to load
  libsqlite3-dev sqlite3
)

if phase packages; then
  c_head "Packages (apt)"
  run sudo apt-get update -qq
  run sudo apt-get install -y "${APT_PACKAGES[@]}"
  [ -z "${DRY_RUN:-}" ] && c_good "installed ${#APT_PACKAGES[@]} apt packages"

  # Debian renames these to avoid collisions; the dotfiles expect the real names.
  [ -x /usr/bin/batcat ] && run ln -sf /usr/bin/batcat "$LOCAL_BIN/bat" && \
    c_info 'linked batcat -> bat'
  [ -x /usr/bin/fdfind ] && run ln -sf /usr/bin/fdfind "$LOCAL_BIN/fd" && \
    c_info 'linked fdfind -> fd'

  # GitHub CLI (own apt repo)
  if ! have gh; then
    run sudo mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | run sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
    run sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | run sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    run sudo apt-get update -qq && run sudo apt-get install -y gh
    c_good 'gh'
  else
    c_info "gh $(gh --version 2>/dev/null | head -1)"
  fi

  # eza (own apt repo; not in Ubuntu until 24.04+)
  if ! have eza; then
    run sudo mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
      | run sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main' \
      | run sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
    run sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    run sudo apt-get update -qq && run sudo apt-get install -y eza || FAILED+=("eza")
    have eza && c_good 'eza'
  else
    c_info 'eza (already installed)'
  fi
fi

# ---------------------------------------------------------------------- tools --

if phase tools; then
  c_head 'Tools (upstream installers -- apt versions are too old)'

  # oh-my-zsh + the two plugins .zshrc expects. Without these zsh errors on start.
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    run sh -c 'RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    c_good 'oh-my-zsh'
  else
    c_info 'oh-my-zsh (already installed)'
  fi
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || \
    run git clone -q https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || \
    run git clone -q https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  c_good 'zsh plugins'

  have starship || { run sh -c 'curl -fsSL https://starship.rs/install.sh | sh -s -- -y'; c_good 'starship'; }
  have zoxide   || { run sh -c 'curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh'; c_good 'zoxide'; }
  have atuin    || { run sh -c 'curl -fsSL https://setup.atuin.sh | sh'; c_good 'atuin'; }

  # lazygit (`lg`)
  if ! have lazygit; then
    url=$(gh_asset jesseduffield/lazygit "${A_LAZYGIT}.tar.gz") || true
    if [ -n "${url:-}" ]; then
      run bash -c "curl -fsSL '$url' | tar -xz -C '$LOCAL_BIN' lazygit"
      c_good 'lazygit'
    else
      FAILED+=("lazygit"); c_err 'lazygit: no release asset found'
    fi
  else
    c_info 'lazygit (already installed)'
  fi

  # git-delta. The tarball has a versioned top-level dir, so extract to a scratch
  # dir and pull the binary out rather than guessing the path.
  if ! have delta; then
    url=$(gh_asset dandavison/delta "${A_DELTA}.tar.gz") || true
    if [ -n "${url:-}" ]; then
      tmp=$(mktemp -d)
      run bash -c "curl -fsSL '$url' | tar -xz -C '$tmp' --strip-components=1"
      if [ -n "${DRY_RUN:-}" ]; then
        c_info "DRY: install delta -> $LOCAL_BIN/delta"
      elif [ -f "$tmp/delta" ]; then
        run install -m 755 "$tmp/delta" "$LOCAL_BIN/delta"
        c_good 'delta'
      else
        FAILED+=("delta")
      fi
      rm -rf "$tmp"
    else
      FAILED+=("delta")
    fi
  else
    c_info 'delta (already installed)'
  fi
fi

# ----------------------------------------------------------------------- node --

if phase node; then
  c_head 'Node + global CLIs'

  if [ ! -d "$HOME/.nvm" ]; then
    run bash -c 'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'
  fi
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

  if have nvm || type nvm >/dev/null 2>&1; then
    run nvm install --lts
    run nvm alias default 'lts/*'
    c_good "node $(node --version 2>/dev/null || echo '?')"
  else
    c_warn 'nvm not loaded -- open a new shell and re-run: ./bootstrap.sh node'
  fi

  have bun || { run bash -c 'curl -fsSL https://bun.sh/install | bash'; c_good 'bun'; }

  if have npm; then
    for pkg in opencode-ai agent-browser; do
      c_info "npm install -g $pkg"
      run npm install -g "$pkg" || FAILED+=("npm: $pkg")
    done
  else
    c_warn 'npm unavailable -- skipping global installs'
  fi

  have claude || { run bash -c 'curl -fsSL https://claude.ai/install.sh | bash'; c_good 'claude'; }
  have rtk    || { run bash -c 'curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh'; c_good 'rtk'; }
fi

# --------------------------------------------------------------------- docker --

if phase docker; then
  c_head 'Docker'
  if ! have docker; then
    run sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL "https://download.docker.com/linux/${ID}/gpg" \
      | run sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    run sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" \
      | run sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    run sudo apt-get update -qq
    run sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
      docker-buildx-plugin docker-compose-plugin
    c_good 'docker + compose'
  else
    c_info "docker $(docker --version 2>/dev/null)"
  fi

  # Run docker without sudo. Requires a new login session to take effect.
  if ! id -nG "$USER" | grep -qw docker; then
    run sudo usermod -aG docker "$USER"
    c_warn "added $USER to the docker group -- log out and back in for it to apply"
  fi
fi

# ------------------------------------------------------------------------- db --

if phase db; then
  c_head 'Database clients (no local servers)'

  run sudo apt-get install -y postgresql-client redis-tools
  c_good 'psql, redis-cli'

  # Microsoft SQL Server tools: sqlcmd + bcp
  if [ ! -x /opt/mssql-tools18/bin/sqlcmd ]; then
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
      | run sudo tee /etc/apt/trusted.gpg.d/microsoft.asc >/dev/null
    curl -fsSL "https://packages.microsoft.com/config/${ID}/${VERSION_ID}/prod.list" \
      | run sudo tee /etc/apt/sources.list.d/mssql-release.list >/dev/null
    run sudo apt-get update -qq
    run sudo env ACCEPT_EULA=Y apt-get install -y mssql-tools18 unixodbc-dev \
      || FAILED+=("mssql-tools18")
  fi
  if [ -x /opt/mssql-tools18/bin/sqlcmd ]; then
    run ln -sf /opt/mssql-tools18/bin/sqlcmd "$LOCAL_BIN/sqlcmd"
    run ln -sf /opt/mssql-tools18/bin/bcp "$LOCAL_BIN/bcp"
    c_good 'sqlcmd, bcp'
  fi

  # Supabase CLI, for the postgres-hosted option
  if ! have supabase; then
    url=$(gh_asset supabase/cli "linux_${DEB_ARCH}.deb") || true
    if [ -n "${url:-}" ]; then
      run bash -c "curl -fsSL '$url' -o /tmp/supabase.deb && sudo dpkg -i /tmp/supabase.deb && rm -f /tmp/supabase.deb"
      c_good 'supabase cli'
    else
      c_warn 'supabase cli: no release asset found'
    fi
  else
    c_info 'supabase (already installed)'
  fi
fi

# ----------------------------------------------------------------------- nvim --

if phase nvim; then
  c_head 'Neovim'
  # apt ships an old Neovim; the config needs a current one for blink.cmp etc.
  need_nvim=1
  if have nvim; then
    v=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    major=${v%%.*}; minor=${v##*.}
    if [ "$major" -gt 0 ] || [ "$minor" -ge 10 ]; then need_nvim=0; c_info "nvim $v (current enough)"; fi
  fi

  if [ "$need_nvim" = 1 ]; then
    url=$(gh_asset neovim/neovim "nvim-${A_NVIM}.tar.gz") || true
    if [ -n "${url:-}" ]; then
      run bash -c "curl -fsSL '$url' -o /tmp/nvim.tar.gz && sudo rm -rf /opt/nvim && sudo mkdir -p /opt/nvim && sudo tar -xzf /tmp/nvim.tar.gz -C /opt/nvim --strip-components=1 && rm -f /tmp/nvim.tar.gz"
      run ln -sf /opt/nvim/bin/nvim "$LOCAL_BIN/nvim"
      c_good "nvim $("$LOCAL_BIN/nvim" --version 2>/dev/null | head -1 || echo installed)"
    else
      FAILED+=("neovim"); c_err 'neovim: no release asset found'
    fi
  fi

  if have nvim && [ -z "${DRY_RUN:-}" ]; then
    nvim --headless '+Lazy! sync' +qa 2>/dev/null || true
    c_good 'plugins synced'
  fi
fi

# ----------------------------------------------------------------------- link --

if phase link; then
  c_head 'Repos + dotfiles'

  [ -d "$DOTFILES_DIR/.git" ] || run git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  [ -d "$AGENT_DIR/.git" ]    || run git clone "$AGENT_REPO" "$AGENT_DIR"

  if [ -z "${DRY_RUN:-}" ]; then
    # tmux is deliberately not stowed here -- not installed on this box.
    ( cd "$DOTFILES_DIR" && stow -R zsh bash git nvim opencode starship vim shell )
    c_good 'stowed: zsh bash git nvim opencode starship vim shell'
  fi

  # Machine-local git identity, mirroring macOS.
  if [ ! -f "$HOME/.gitconfig.local" ]; then
    if [ -n "${DRY_RUN:-}" ]; then
      c_info "DRY: write $HOME/.gitconfig.local"
    else
      cat > "$HOME/.gitconfig.local" <<'EOF'
[user]
	name = Justin Cordova
	email = CHANGE_ME
[core]
	autocrlf = input
[credential]
	helper = cache --timeout=3600
EOF
      c_warn "created $HOME/.gitconfig.local -- set your email"
    fi
  fi

  # command -v is empty until the packages phase has actually installed zsh.
  zsh_path=$(command -v zsh || echo /usr/bin/zsh)
  if [ "$SHELL" != "$zsh_path" ]; then
    c_warn "default shell is $SHELL; switch with: chsh -s $zsh_path"
  fi
fi

# --------------------------------------------------------------------- agents --

if phase agents; then
  c_head 'Agent config (Claude Code + OpenCode)'
  if [ -x "$AGENT_DIR/install.sh" ]; then
    run "$AGENT_DIR/install.sh"
  else
    c_warn "not found: $AGENT_DIR/install.sh"
  fi

  for k in CONTEXT7_API_KEY FIRECRAWL_API_KEY; do
    if [ -z "${!k:-}" ]; then
      c_warn "env var $k is not set -- add it to ~/.zshrc.local"
    fi
  done

  if [ ! -f "$HOME/.opencode/opencode.json" ]; then
    if [ -n "${DRY_RUN:-}" ]; then
      c_info "DRY: write $HOME/.opencode/opencode.json"
    else
    mkdir -p "$HOME/.opencode"
    cat > "$HOME/.opencode/opencode.json" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["opencode-gemini-auth@latest", "opencode-claude-auth@latest", "opencode-mystatus"],
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "headers": { "CONTEXT7_API_KEY": "{env:CONTEXT7_API_KEY}" },
      "enabled": true
    },
    "firecrawl": {
      "type": "local",
      "command": ["npx", "-y", "firecrawl-mcp"],
      "environment": { "FIRECRAWL_API_KEY": "{env:FIRECRAWL_API_KEY}" },
      "enabled": true
    }
  }
}
EOF
      c_good "wrote $HOME/.opencode/opencode.json"
    fi
  fi

  have rtk && c_warn 'run: rtk init -g'
fi

# -------------------------------------------------------------------- summary --

c_head 'Summary'
if [ ${#FAILED[@]} -gt 0 ]; then
  c_warn "${#FAILED[@]} item(s) failed:"
  for f in "${FAILED[@]}"; do c_err "  $f"; done
else
  c_good 'all phases completed'
fi

cat <<'EOF'

Next:
  1. exec zsh          (or log out/in if you ran chsh)
  2. rtk init -g
  3. gh auth login
  4. claude   -> /login
  5. opencode -> /connect
  6. Set your email in ~/.gitconfig.local
  7. Put API keys in ~/.zshrc.local

From Windows, forward the dev server instead of exposing it:
  ssh -L 3000:localhost:3000 user@linux-box
  # then browse to http://localhost:3000 on Windows

EOF
