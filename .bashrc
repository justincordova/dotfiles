############################################
# 🧠 Interactive Shell Check
############################################
case $- in
  *i*) ;;
    *) return;;
esac

############################################
# 🚀 Oh My Bash Setup
############################################
export OSH="$HOME/.oh-my-bash"
OSH_THEME="ht"

# Optional: Use custom folder for OMB (uncomment if needed)
# OSH_CUSTOM=/path/to/new-custom-folder

# Prevent Oh My Bash from overwriting some default aliases
# OMB_DEFAULT_ALIASES="check"

# Disable sudo inside plugins/themes (optional)
OMB_USE_SUDO=true

# Completions to load (too many can slow startup)
completions=(git composer ssh)

# Aliases to load
aliases=(general)

# Plugins to load
plugins=(git bashmarks)

# Conditional plugins (example)
# if [ "$DISPLAY" ] || [ "$SSH" ]; then
#   plugins+=(tmux-autoattach)
# fi

# Load Oh My Bash
source "$OSH/oh-my-bash.sh"

############################################
# 🔁 Aliases
############################################
alias icloud="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/"

############################################
# 🌍 Environment Variables
############################################

# Python path (Anaconda)
export PYTHONPATH="$PYTHONPATH:/opt/anaconda3/lib/python3.12/site-packages"

# Language (uncomment if needed)
# export LANG=en_US.UTF-8

# Man pages (uncomment if needed)
# export MANPATH="/usr/local/man:$MANPATH"

# Compilation flags (uncomment if compiling C/C++ locally)
# export ARCHFLAGS="-arch x86_64"

# SSH key path (uncomment if needed)
# export SSH_KEY_PATH="$HOME/.ssh/rsa_id"

############################################
# 📝 Editor Settings (optional)
############################################
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

############################################
# ⚙️ Optional Behavior Customization
############################################

# Uncomment if desired behavior is needed:
# OMB_CASE_SENSITIVE="true"
# OMB_HYPHEN_SENSITIVE="false"
# DISABLE_AUTO_UPDATE="true"
# export UPDATE_OSH_DAYS=13
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
# ENABLE_CORRECTION="true"
# COMPLETION_WAITING_DOTS="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"
# SCM_GIT_DISABLE_UNTRACKED_DIRTY="true"
# SCM_GIT_IGNORE_UNTRACKED="true"
# HIST_STAMPS='yyyy-mm-dd'

