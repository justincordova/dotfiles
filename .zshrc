# Ghostty Auto-Launch Hook
# Check immediately if we need to run a pending command
if [[ -f "$HOME/.ghostty_launch_pending" ]]; then
    # Source the pending command
    . "$HOME/.ghostty_launch_pending"
    # Cleanup
    rm "$HOME/.ghostty_launch_pending"
fi

##### Environment Setup

# Oh My Zsh directory
export ZSH="$HOME/.oh-my-zsh"

# Disable Oh My Zsh themes (Starship handles prompt)
ZSH_THEME=""
#ht

# BAT theme for pretty output
export BAT_THEME="Twork"

# Path additions
export PATH="/opt/homebrew/bin:$PATH"

# Bun setup
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

##### Plugins & Oh My Zsh Init

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  web-search
  z
)

source $ZSH/oh-my-zsh.sh

##### Conda Initialization

__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
elif [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
    . "/opt/anaconda3/etc/profile.d/conda.sh"
fi
unset __conda_setup

##### Completions & Init

autoload -U compinit; compinit

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Faster completions cache
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache

##### Aliases

# Navigation
alias icloud="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/"
alias codep='code .. --reuse-window'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull --rebase'
alias gco='git checkout'
alias gl='git log --oneline --graph --decorate'
alias lg="lazygit"

# General
alias c='clear'
alias reload='source ~/.zshrc'

# Python
alias py3='python3'
alias py='python'

# macOS colored ls
alias ls='ls -G'

# Make + cd
mkcd() {
  mkdir -p "$1" && cd "$1"
}

##### History Config

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

setopt inc_append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify

##### Config Flags

ENABLE_CORRECTION="true"

##### Starship Prompt

eval "$(starship init zsh)"

##### NVM Setup

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

##### CotEditor Function

cot() {
  if [ $# -eq 0 ]; then
    # no args -> just open CotEditor
    open -a CotEditor
  else
    # pass args -> open files with CotEditor
    open -a CotEditor "$@"
  fi
}
alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs'

# Added by Antigravity
export PATH="/Users/justincordova/.antigravity/antigravity/bin:$PATH"

alias claude="/Users/justincordova/.claude/local/claude"
alias fishy="asciiquarium"

function idlem() {
  echo "Choose a terminal idle program:"
  echo "1) Asciiquarium"
  echo "2) Pipes"
  echo "3) Cbonsai"
  echo "4) TTY Clock"
  echo -n "> "
  read -k 1 opt
  echo "" # New line after input

  case $opt in
    1) asciiquarium ;;
    2) pipes.sh ;;
    3) cbonsai ;;
    4) tty-clock -s -c -C 5 -t ;;
    *) echo "Invalid option." ;;
  esac
}
