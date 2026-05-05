export ZSH="$HOME/.oh-my-zsh"
export BAT_THEME="Twork"
export BUN_INSTALL="$HOME/.bun"
export NVM_DIR="$HOME/.nvm"
export PATH="/Users/justincordova/.antigravity/antigravity/bin:$BUN_INSTALL/bin:/opt/homebrew/bin:$PATH"
# Add Go binaries to PATH
export PATH="$PATH:$(go env GOPATH)/bin"

# --- Zsh Config ---
ZSH_THEME=""
ENABLE_CORRECTION="true"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search z)
source $ZSH/oh-my-zsh.sh
unsetopt correct
unsetopt correctall


# --- History & Completion ---
HISTSIZE=10000; SAVEHIST=10000; HISTFILE=~/.zsh_history
setopt inc_append_history share_history hist_ignore_dups hist_ignore_space hist_verify
autoload -U compinit; compinit
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache
# --- Tools Initialization ---
eval "$(starship init zsh)"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Conda
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then eval "$__conda_setup"; elif [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then . "/opt/anaconda3/etc/profile.d/conda.sh"; fi; unset __conda_setup

# --- Aliases ---
alias c='clear'
alias reload='source ~/.zshrc'
alias ls='eza'
alias ll='eza -la'
alias l='eza -l'
alias lt='eza --tree'

# Navigation
alias icloud="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/"
alias v="nvim"
alias obi="cd /Users/justincordova/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/obi"
alias codep='code .. --reuse-window'
alias cc='claude'
alias oc='opencode'
alias dc='dotcor'
ne() {
  if [[ -n "$1" ]]; then
    if [[ -d "$1" ]]; then
      NVIM_NO_DASHBOARD=1 nvim -c "cd $1" -c "Neotree reveal" -c "wincmd l" -c "close" -c "1bwipeout"
    else
      echo "Error: '$1' is not a directory"
      return 1
    fi
  else
    NVIM_NO_DASHBOARD=1 nvim -c "Neotree reveal" -c "wincmd l" -c "close" -c "1bwipeout"
  fi
}

# Git
alias lg="lazygit"
alias gmp="git checkout main && git pull"

# Dev / Misc
alias py3='python3'
alias py='python'
alias fishy="asciiquarium"
alias ghd='gh dash'

# --- Functions ---
mkcd() { mkdir -p "$1" && cd "$1"; }
cot() { if [ $# -eq 0 ]; then open -a CotEditor; else open -a CotEditor "$@"; fi }

idlem() {
  echo "1) Asciiquarium\n2) Pipes\n3) Cbonsai\n4) TTY Clock\n> "
  read -k 1 opt; echo ""
  case $opt in
    1) asciiquarium ;; 2) pipe.sh ;; 3) cbonsai ;; 4) tty-clock -s -c -C 5 -t ;; *) echo "Invalid option." ;; 
  esac
}

# --- Auto-start ---
if command -v tmux &>/dev/null && [ -z "$TMUX" ] && [ "$TERM_PROGRAM" = "ghostty" ]; then
  tmux attach -t main || tmux new -s main
fi
export PATH="$HOME/.local/bin:$PATH"
export TERM=xterm-256color

# bun completions
[ -s "/Users/justincordova/.bun/_bun" ] && source "/Users/justincordova/.bun/_bun"
