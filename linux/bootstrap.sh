#!/usr/bin/env bash
#
# Provision an Ubuntu, Debian or Fedora dev box to match the macOS setup.
# Idempotent -- safe to re-run. Phases can be run in isolation.
#
#   ./bootstrap.sh                  # every default phase
#   ./bootstrap.sh packages node    # only those phases
#   ./bootstrap.sh langs            # opt-in: Java, .NET, Rust
#   DRY_RUN=1 ./bootstrap.sh        # print install actions, change nothing
#
# Phases run in this order, and the order matters:
#   packages ssh link tools node docker db nvim agents [langs]
# `link` precedes `tools` so the stowed ~/.zshrc exists before oh-my-zsh runs.
# Bracketed phases only run when named.
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

OPTIONAL_PHASES=(langs)

phase() {
  local p
  if [ ${#PHASES[@]} -eq 0 ]; then
    for p in "${OPTIONAL_PHASES[@]}"; do [ "$p" = "$1" ] && return 1; done
    return 0
  fi
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

# shellcheck disable=SC1091
. /etc/os-release

# Package manager family. Only the package-install steps branch on this;
# everything fetched from upstream (GitHub releases, nvm, Go, rustup, npm) is
# distro-neutral.
if [ "${ID:-}" = fedora ] && have dnf; then
  PM=dnf
elif have apt-get && [[ " ${ID:-} ${ID_LIKE:-} " =~ \ (debian|ubuntu)\  ]]; then
  PM=apt
else
  echo "Unsupported distro: ${PRETTY_NAME:-unknown}. Supported: Ubuntu, Debian, Fedora." >&2
  exit 1
fi

# Debian-family repos (Docker, Microsoft) are keyed by the *base* distro.
# Derivatives (Mint, Pop!_OS) report their own ID/version, so map them back.
if [ "$PM" = apt ]; then
  case "$ID" in
    ubuntu|debian) APT_ID=$ID; APT_CODENAME=${VERSION_CODENAME:-} ;;
    *) if [ -n "${UBUNTU_CODENAME:-}" ]; then APT_ID=ubuntu; APT_CODENAME=$UBUNTU_CODENAME
       else APT_ID=debian; APT_CODENAME=${DEBIAN_CODENAME:-${VERSION_CODENAME:-}}; fi ;;
  esac
  case "$APT_CODENAME" in
    jammy) APT_VERSION=22.04 ;; noble) APT_VERSION=24.04 ;;
    bookworm) APT_VERSION=12 ;; trixie) APT_VERSION=13 ;;
    *) APT_VERSION=${VERSION_ID:-} ;;
  esac
fi

case "$(uname -m)" in
  x86_64)        ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac
c_good "${PRETTY_NAME:-unknown}  ($ARCH, $PM)"

# Release assets name architectures inconsistently across projects.
case "$ARCH" in
  amd64) A_LAZYGIT=linux_x86_64; A_LAZYDOCKER=Linux_x86_64; A_DIFFNAV=Linux_x86_64; A_DELTA=x86_64-unknown-linux-gnu; A_NVIM=linux-x86_64; A_TS=linux-x64 ;;
  arm64) A_LAZYGIT=linux_arm64;  A_LAZYDOCKER=Linux_arm64;  A_DIFFNAV=Linux_arm64;  A_DELTA=aarch64-unknown-linux-gnu; A_NVIM=linux-arm64;  A_TS=linux-arm64 ;;
esac

pkg_refresh() {
  # dnf refreshes stale metadata on its own.
  if [ "$PM" = apt ]; then run sudo apt-get update -qq; fi
}

pkg_install() {
  case "$PM" in
    apt) run sudo apt-get install -y "$@" ;;
    dnf) run sudo dnf install -y "$@" ;;
  esac
}

# Write a repo definition from a URL (dnf) -- used for Docker and Microsoft.
dnf_add_repo() {
  curl -fsSL "$1" | run sudo tee "/etc/yum.repos.d/$2.repo" >/dev/null
}

if ! sudo -n true 2>/dev/null; then
  c_warn 'sudo will prompt for your password.'
fi

mkdir -p "$LOCAL_BIN"
# Tools land here (zoxide, lazygit, nvim, claude, rtk). Without it on PATH,
# `have` misses them, re-runs reinstall them, and the nvim phase skips its sync.
export PATH="$LOCAL_BIN:$PATH"

# ------------------------------------------------------------------- packages --

# Same tools, per-family names; lines correspond across the two lists.
APT_PACKAGES=(
  zsh stow tmux                                     # shell
  build-essential pkg-config                        # build
  curl wget git git-lfs unzip ca-certificates gnupg # fetch
  ripgrep fd-find bat jq fzf tree htop shellcheck   # cli
  lsof netcat-openbsd                               # `ports` alias, README's nc checks
  xclip                                             # clipboard over X11 forwarding
  python3 python3-pip python3-venv                  # python
  libsqlite3-dev sqlite3                            # clib for nvim's sqlite.lua
)
DNF_PACKAGES=(
  zsh stow tmux
  gcc gcc-c++ make pkgconf-pkg-config
  curl wget2-wget git git-lfs unzip tar gzip ca-certificates gnupg2
  ripgrep fd-find bat jq fzf tree htop ShellCheck
  lsof nmap-ncat
  xclip
  python3 python3-pip                               # venv is built into python3
  sqlite-devel sqlite
  # Fedora packages these; Debian needs their upstream repos (below).
  gh eza
)

if phase packages; then
  c_head "Packages ($PM)"
  pkg_refresh
  if [ "$PM" = apt ]; then
    pkg_install "${APT_PACKAGES[@]}"
  else
    pkg_install "${DNF_PACKAGES[@]}"
  fi
  [ -z "${DRY_RUN:-}" ] && c_good "installed base packages"

  # Debian renames these to avoid collisions; the dotfiles expect the real names.
  [ -x /usr/bin/batcat ] && run ln -sf /usr/bin/batcat "$LOCAL_BIN/bat" && \
    c_info 'linked batcat -> bat'
  [ -x /usr/bin/fdfind ] && run ln -sf /usr/bin/fdfind "$LOCAL_BIN/fd" && \
    c_info 'linked fdfind -> fd'
fi

# GitHub CLI and eza come from their own apt repos on the Debian family.
if phase packages && [ "$PM" = apt ]; then
  # GitHub CLI (own apt repo)
  if ! have gh; then
    run sudo mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | run sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
    run sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
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

# ------------------------------------------------------------------------ ssh --

# This box is driven over SSH from Windows. Ubuntu Desktop ships no server;
# Fedora Workstation ships one but leaves it disabled.
if phase ssh; then
  c_head 'SSH server'
  pkg_install openssh-server
  # The unit is `ssh` on the Debian family, `sshd` on Fedora. systemctl fails
  # in containers and other non-systemd environments; that shouldn't abort
  # the rest of the run.
  ssh_unit=ssh; [ "$PM" = dnf ] && ssh_unit=sshd
  if run sudo systemctl enable --now "$ssh_unit" 2>/dev/null; then
    c_good 'sshd enabled'
  else
    c_warn 'could not enable sshd via systemctl -- start it manually'
  fi

  # Fedora runs firewalld. Workstation's zone already allows ssh, Server's may
  # not; adding it is a no-op when present.
  if have firewall-cmd && sudo firewall-cmd --state >/dev/null 2>&1; then
    run sudo firewall-cmd --permanent --add-service=ssh >/dev/null \
      && run sudo firewall-cmd --reload >/dev/null && c_good 'firewalld: ssh allowed'
  fi

  # Key-only login, but never before a key is in place, or this would lock
  # you out. sshd takes the *first* value it reads, and drop-ins load in
  # lexical order, so 10- beats cloud-init's 50-cloud-init.conf and Fedora's
  # 50-redhat.conf.
  hardening=/etc/ssh/sshd_config.d/10-dotfiles.conf
  if [ -s "$HOME/.ssh/authorized_keys" ]; then
    if [ ! -f "$hardening" ]; then
      printf '%s\n' 'PasswordAuthentication no' 'KbdInteractiveAuthentication no' \
        | run sudo tee "$hardening" >/dev/null
      # `sshd -t` refuses to run without its privsep dir, which socket-activated
      # sshd (Ubuntu 24.04+) only creates on the first connection.
      run sudo mkdir -p /run/sshd
      if [ -n "${DRY_RUN:-}" ] || sudo sshd -t; then
        run sudo systemctl reload "$ssh_unit" 2>/dev/null || true
        c_good 'password login disabled (key-only)'
      else
        run sudo rm -f "$hardening"
        c_err 'sshd config test failed -- left password login on'
      fi
    else
      c_info 'key-only login (already configured)'
    fi
  else
    c_warn 'no ~/.ssh/authorized_keys -- password login left ON'
    c_warn '  add your Windows key, then re-run: ./bootstrap.sh ssh'
  fi
fi

# ----------------------------------------------------------------------- link --

if phase link; then
  c_head 'Repos + dotfiles'

  [ -d "$DOTFILES_DIR/.git" ] || run git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  [ -d "$AGENT_DIR/.git" ]    || run git clone "$AGENT_REPO" "$AGENT_DIR"

  # Stow is all-or-nothing: one pre-existing real file (Ubuntu ships its own
  # ~/.bashrc and ~/.profile) aborts every package, silently leaving the box
  # unconfigured. Move any conflicting regular file aside first.
  # The opencode entries exist if opencode was launched before bootstrap.
  STOW_TARGETS=(
    "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.vimrc"
    "$HOME/.gitconfig" "$HOME/.gitignore_global" "$HOME/.shell_aliases"
    "$HOME/.config/starship.toml" "$HOME/.config/nvim"
    "$HOME/.config/opencode/opencode.json" "$HOME/.config/opencode/tui.json"
    "$HOME/.tmux.conf" "$HOME/.tmux.theme.conf" "$HOME/.config/gh-dash/config.yml"
  )
  for t in "${STOW_TARGETS[@]}"; do
    # -e and not -L: a real file/dir, not a symlink we own.
    if [ -e "$t" ] && [ ! -L "$t" ]; then
      run mv "$t" "$t.pre-stow"
      [ -z "${DRY_RUN:-}" ] && c_warn "moved $t -> $t.pre-stow"
    fi
  done

  if [ -z "${DRY_RUN:-}" ]; then
    # Pre-create ~/.config/opencode so stow links its entries one by one. Left
    # absent, stow symlinks the whole directory into the repo and opencode then
    # writes secrets.env, service.json and node_modules inside the checkout.
    mkdir -p "$HOME/.config/opencode"
    ( cd "$DOTFILES_DIR" && stow -R zsh bash git nvim opencode starship vim shell tmux gh-dash )
    c_good 'stowed: zsh bash git nvim opencode starship vim shell tmux gh-dash'
  fi

  # Machine-local git settings. Identity is tracked in git/.gitconfig.
  if [ ! -f "$HOME/.gitconfig.local" ]; then
    if [ -n "${DRY_RUN:-}" ]; then
      c_info "DRY: write $HOME/.gitconfig.local"
    else
      cat > "$HOME/.gitconfig.local" <<'EOF'
[core]
	autocrlf = input
[credential]
	helper = cache --timeout=3600
EOF
      c_good "created $HOME/.gitconfig.local"
    fi
  fi

  # command -v is empty until the packages phase has actually installed zsh.
  zsh_path=$(command -v zsh || echo /usr/bin/zsh)
  if [ "$SHELL" != "$zsh_path" ]; then
    c_warn "default shell is $SHELL; switch with: chsh -s $zsh_path"
  fi
fi

# ---------------------------------------------------------------------- tools --

if phase tools; then
  c_head 'Tools (upstream installers -- distro versions are too old)'

  # oh-my-zsh + the two plugins .zshrc expects. Without these zsh errors on start.
  #
  # This phase runs *after* `link` on purpose. KEEP_ZSHRC only stops oh-my-zsh
  # replacing an .zshrc that already exists -- with none present it writes its
  # own template regardless, which then blocks `stow zsh` with a conflict and
  # leaves you on the template instead of your real config.
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    run sh -c 'RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    c_good 'oh-my-zsh'

    # Belt and braces: if it clobbered the symlink anyway, put ours back.
    if [ -z "${DRY_RUN:-}" ] && [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
      c_warn 'oh-my-zsh replaced ~/.zshrc -- restoring the stowed one'
      mv "$HOME/.zshrc" "$HOME/.zshrc.oh-my-zsh-template"
      ( cd "$DOTFILES_DIR" && stow -R zsh )
    fi
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

  # nvim-treesitter (main branch) compiles parsers with the tree-sitter CLI;
  # without it syntax highlighting silently stays off.
  if ! have tree-sitter; then
    url=$(gh_asset tree-sitter/tree-sitter "tree-sitter-${A_TS}.gz") || true
    if [ -n "${url:-}" ]; then
      run bash -c "curl -fsSL '$url' | gunzip > '$LOCAL_BIN/tree-sitter' && chmod 755 '$LOCAL_BIN/tree-sitter'"
      c_good 'tree-sitter'
    else
      FAILED+=("tree-sitter"); c_err 'tree-sitter: no release asset found'
    fi
  else
    c_info 'tree-sitter (already installed)'
  fi

  # Go: gopls, delve, golangci-lint and goimports are built by Mason with
  # `go install`, so they all fail without a toolchain. Distro golang lags.
  if [ ! -x /usr/local/go/bin/go ]; then
    gover=$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1) || true
    if [ -n "${gover:-}" ]; then
      run bash -c "curl -fsSL 'https://go.dev/dl/${gover}.linux-${ARCH}.tar.gz' -o /tmp/go.tar.gz && sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go.tar.gz && rm -f /tmp/go.tar.gz"
      c_good "$gover"
    else
      FAILED+=("go"); c_err 'go: could not resolve latest version'
    fi
  else
    c_info "$(/usr/local/go/bin/go version)"
  fi
  export PATH="/usr/local/go/bin:$PATH"

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

  if ! have lazydocker; then
    url=$(gh_asset jesseduffield/lazydocker "${A_LAZYDOCKER}.tar.gz") || true
    if [ -n "${url:-}" ]; then
      run bash -c "curl -fsSL '$url' | tar -xz -C '$LOCAL_BIN' lazydocker"
      c_good 'lazydocker'
    else
      FAILED+=("lazydocker"); c_err 'lazydocker: no release asset found'
    fi
  else
    c_info 'lazydocker (already installed)'
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

  # gh-dash (`ghd`) and the diff pager its config uses (pager.diff: diffnav).
  # `gh extension install` works before `gh auth login`, but `gh extension
  # list` doesn't -- so check for the installed directory instead.
  if have gh && [ ! -d "${XDG_DATA_HOME:-$HOME/.local/share}/gh/extensions/gh-dash" ]; then
    run gh extension install dlvhdr/gh-dash && c_good 'gh-dash' || FAILED+=("gh-dash")
  else
    c_info 'gh-dash (already installed)'
  fi
  if ! have diffnav; then
    url=$(gh_asset dlvhdr/diffnav "${A_DIFFNAV}.tar.gz") || true
    if [ -n "${url:-}" ]; then
      run bash -c "curl -fsSL '$url' | tar -xz -C '$LOCAL_BIN' diffnav"
      c_good 'diffnav'
    else
      FAILED+=("diffnav"); c_err 'diffnav: no release asset found'
    fi
  else
    c_info 'diffnav (already installed)'
  fi

  # tmux plugin manager plus the plugins .tmux.conf declares. install_plugins
  # asks a running server for the config, so start a throwaway detached one.
  tpm="$HOME/.tmux/plugins/tpm"
  [ -d "$tpm" ] || run git clone -q https://github.com/tmux-plugins/tpm "$tpm"
  if have tmux && [ -z "${DRY_RUN:-}" ]; then
    tmux new-session -d -s bootstrap-tpm 2>/dev/null || true
    if "$tpm/bin/install_plugins" >/dev/null 2>&1; then
      c_good 'tmux plugins'
    else
      FAILED+=("tmux plugins")
    fi
    tmux kill-session -t bootstrap-tpm 2>/dev/null || true
  fi
fi

# ----------------------------------------------------------------------- node --

if phase node; then
  c_head 'Node + global CLIs'

  # The nvm and bun installers append to ~/.bashrc / ~/.zshrc, which are stowed
  # symlinks -- that would dirty the tracked files. Both rc files already load
  # nvm and bun, so stop the installers touching them (PROFILE / SHELL).
  if [ ! -d "$HOME/.nvm" ]; then
    run bash -c 'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash'
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

  have bun || [ -x "$HOME/.bun/bin/bun" ] || \
    { run bash -c 'curl -fsSL https://bun.sh/install | SHELL=/bin/sh bash'; c_good 'bun'; }

  # OpenCode 2 ships as @opencode/cli. The older `opencode-ai` package (and the
  # opencode.ai/install script) are still OpenCode 1, which cannot load the v2
  # plugins in opencode/.config/opencode/v2-plugins.
  if have npm; then
    for pkg in @opencode/cli agent-browser pnpm; do
      c_info "npm install -g $pkg"
      run npm install -g "$pkg" || FAILED+=("npm: $pkg")
    done
    # agent-browser drives a real Chrome; fetch it plus its shared libraries.
    # Chrome for Testing has no linux-arm64 build.
    if [ "$ARCH" = arm64 ]; then
      c_warn 'agent-browser: no Chrome for linux-arm64 -- install chromium and pass --executable-path'
    elif have agent-browser; then
      run agent-browser install --with-deps || FAILED+=("agent-browser install")
    fi
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
    if [ "$PM" = apt ]; then
      run sudo install -m 0755 -d /etc/apt/keyrings
      curl -fsSL "https://download.docker.com/linux/${APT_ID}/gpg" \
        | run sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
      run sudo chmod a+r /etc/apt/keyrings/docker.gpg
      echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${APT_ID} ${APT_CODENAME} stable" \
        | run sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    else
      # Fedora's own moby-engine/podman-docker would conflict with docker-ce.
      dnf_add_repo https://download.docker.com/linux/fedora/docker-ce.repo docker-ce
    fi
    pkg_refresh
    pkg_install docker-ce docker-ce-cli containerd.io \
      docker-buildx-plugin docker-compose-plugin
    c_good 'docker + compose'
  else
    c_info "docker $(docker --version 2>/dev/null)"
  fi

  # Debian's package starts the daemon on install; Fedora's doesn't.
  if [ "$PM" = dnf ]; then
    run sudo systemctl enable --now docker 2>/dev/null \
      || c_warn 'could not enable docker via systemctl -- start it manually'
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

  # Fedora replaced Redis with Valkey; valkey-compat-redis provides redis-cli.
  if [ "$PM" = apt ]; then
    pkg_install postgresql-client redis-tools
  else
    pkg_install postgresql valkey-compat-redis
  fi
  c_good 'psql, redis-cli'

  # Microsoft SQL Server tools: sqlcmd + bcp. A failure here is recorded and
  # skipped: under set -e it would otherwise abort every later phase.
  if [ ! -x /opt/mssql-tools18/bin/sqlcmd ]; then
    if [ "$PM" = apt ]; then
      # packages-microsoft-prod.deb installs the repo *and* the keyring its
      # signed-by points at; a hand-written prod.list without it fails apt
      # update with NO_PUBKEY. Files from that old setup clash with the .deb.
      run sudo rm -f /etc/apt/sources.list.d/mssql-release.list /etc/apt/trusted.gpg.d/microsoft.asc
      ms_install() {
        run bash -c "curl -fsSL 'https://packages.microsoft.com/config/${APT_ID}/${APT_VERSION}/packages-microsoft-prod.deb' -o /tmp/packages-microsoft-prod.deb \
            && sudo dpkg -i /tmp/packages-microsoft-prod.deb && rm -f /tmp/packages-microsoft-prod.deb" \
          && pkg_refresh \
          && run sudo env ACCEPT_EULA=Y apt-get install -y mssql-tools18 unixodbc-dev
      }
    else
      # Microsoft publishes no Fedora repo; its RHEL one installs cleanly.
      ms_install() {
        dnf_add_repo https://packages.microsoft.com/config/rhel/9/prod.repo mssql-release \
          && run sudo env ACCEPT_EULA=Y dnf install -y mssql-tools18 unixODBC-devel
      }
    fi
    ms_install || { FAILED+=("mssql-tools18"); c_err 'mssql-tools18 failed -- other phases continue'; }
  fi
  if [ -x /opt/mssql-tools18/bin/sqlcmd ]; then
    run ln -sf /opt/mssql-tools18/bin/sqlcmd "$LOCAL_BIN/sqlcmd"
    run ln -sf /opt/mssql-tools18/bin/bcp "$LOCAL_BIN/bcp"
    c_good 'sqlcmd, bcp'
  fi

  # Supabase CLI, for the postgres-hosted option
  if ! have supabase; then
    ext=deb; [ "$PM" = dnf ] && ext=rpm
    url=$(gh_asset supabase/cli "linux_${ARCH}.${ext}") || true
    if [ -n "${url:-}" ]; then
      run bash -c "curl -fsSL '$url' -o /tmp/supabase.$ext && sudo $PM install -y /tmp/supabase.$ext && rm -f /tmp/supabase.$ext"
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
  # Distros ship an old Neovim; the config needs a current one for blink.cmp etc.
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

  # restore, not sync: sync bumps every plugin and rewrites the tracked
  # lazy-lock.json; restore installs exactly the versions it pins.
  # The config's first-run bootstrap clones lazy.nvim at its latest commit and
  # restore can't roll back the running plugin manager, so the lockfile still
  # gets that one line rewritten. Put it back -- but only if it was clean.
  if have nvim && [ -z "${DRY_RUN:-}" ]; then
    lock=nvim/.config/nvim/lazy-lock.json
    lock_clean=0
    git -C "$DOTFILES_DIR" diff --quiet -- "$lock" && lock_clean=1
    nvim --headless '+Lazy! restore' +qa >/dev/null 2>&1 || true
    [ "$lock_clean" = 1 ] && git -C "$DOTFILES_DIR" checkout -q -- "$lock"
    c_good 'plugins restored from lazy-lock.json'
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

  # The tracked opencode.json loads ./v2-plugins/{anthropic,quotas}, which
  # import from their own node_modules. --ignore-scripts: opencode-mystatus's
  # installer rewrites opencode config, which these local ports replace.
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  plugins_dir="$DOTFILES_DIR/opencode/.config/opencode/v2-plugins"
  if have npm; then
    run bash -c "cd '$plugins_dir' && npm ci --ignore-scripts --no-audit --no-fund" \
      && c_good 'opencode v2-plugins deps' || FAILED+=("v2-plugins npm ci")
  else
    FAILED+=("v2-plugins npm ci"); c_err 'npm unavailable -- run the node phase first'
  fi

  # RTK's shell hook. ~/.opencode applies to every project under $HOME. Do not
  # use `rtk init --opencode`: it writes an OpenCode 1 plugin.
  run mkdir -p "$HOME/.opencode/plugins"
  run ln -sfn "$HOME/.config/opencode/v2-plugins/rtk.ts" "$HOME/.opencode/plugins/rtk.ts"
  c_good 'rtk opencode plugin'

  # Older bootstraps wrote this file with opencode-claude-auth, which fights the
  # local anthropic plugin over refresh tokens (see commit d30acf2).
  if [ -f "$HOME/.opencode/opencode.json" ]; then
    c_warn "$HOME/.opencode/opencode.json exists -- everything now lives in the"
    c_warn "  tracked config; delete it unless it holds something deliberate"
  fi

  # OpenCode rewrites cli.json in place, which would replace a stow symlink,
  # so it is seeded as a copy rather than linked.
  if [ ! -f "$HOME/.config/opencode/cli.json" ]; then
    run cp "$DOTFILES_DIR/linux/opencode-cli.json" "$HOME/.config/opencode/cli.json"
    c_good 'seeded opencode cli.json'
  fi

  # Sourced by ~/.zshenv; referenced from opencode.json as {env:NAME}.
  secrets="$HOME/.config/opencode/secrets.env"
  if [ ! -f "$secrets" ]; then
    if [ -n "${DRY_RUN:-}" ]; then
      c_info "DRY: write $secrets"
    else
      cat > "$secrets" <<'EOF'
# Secrets for OpenCode MCP servers. Untracked; sourced by ~/.zshenv.
export CONTEXT7_API_KEY=
export FIRECRAWL_API_KEY=
EOF
      chmod 600 "$secrets"
      c_warn "created $secrets -- fill in the API keys"
    fi
  fi
fi

# ---------------------------------------------------------------------- langs --

# Opt-in (./bootstrap.sh langs). Toolchains for nvim's Java, C# and Rust
# tooling -- only worth the disk and time if you write those here.
if phase langs; then
  c_head 'Language toolchains (Java, .NET, Rust)'

  # jdtls needs Java 21+. Fedora dropped 21; 25 is its current LTS.
  if ! have java; then
    jdk=openjdk-21-jdk-headless; [ "$PM" = dnf ] && jdk=java-25-openjdk-devel
    pkg_install "$jdk" && c_good "$jdk" || FAILED+=("$jdk (not in this release's repos?)")
  else
    c_info "$(java -version 2>&1 | head -1)"
  fi

  # OmniSharp needs a .NET runtime; the SDK brings one. .NET 10 is the current
  # LTS (8 left support Nov 2026). Ubuntu and Fedora package it natively;
  # Debian gets it from the Microsoft repo the db phase adds.
  if ! have dotnet; then
    pkg_install dotnet-sdk-10.0 && c_good 'dotnet sdk 10' \
      || FAILED+=("dotnet-sdk-10.0 (on Debian, run the db phase first)")
  else
    c_info "dotnet $(dotnet --version 2>/dev/null)"
  fi

  # rustfmt and cargo. --no-modify-path: .zshrc already adds ~/.cargo/bin, and
  # the installer would otherwise write into the stowed rc files.
  if [ ! -x "$HOME/.cargo/bin/rustup" ]; then
    run bash -c 'curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path'
    c_good 'rustup + stable toolchain'
  else
    c_info "$("$HOME/.cargo/bin/rustc" --version 2>/dev/null)"
  fi
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
  1. From Windows: type $HOME\.ssh\id_ed25519.pub | ssh user@linux-box "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
     then here: ./bootstrap.sh ssh   (turns off password login)
  2. chsh -s "$(command -v zsh)", then log out and back in
  3. Fill in API keys in ~/.config/opencode/secrets.env
  4. rtk init -g        (Claude Code hook; NOT --opencode)
  5. gh auth login
  6. claude   -> /login
  7. opencode -> /connect  (Anthropic, Google), /mcps for supabase + atlassian
  8. Optional: ./bootstrap.sh langs   (Java, .NET, Rust for nvim)

From Windows, forward the dev server instead of exposing it:
  ssh -L 3000:localhost:3000 user@linux-box
  # then browse to http://localhost:3000 on Windows

EOF
