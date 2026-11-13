# Sourced by EVERY zsh invocation (interactive or not), unlike .zshrc.
# Anything that spawns a non-interactive shell -- including the OpenCode
# background service that resolves {env:...} references -- picks secrets up here.
[ -f "$HOME/.config/opencode/secrets.env" ] && source "$HOME/.config/opencode/secrets.env"
