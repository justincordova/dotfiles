#!/usr/bin/env bash

THEME="$1"
THEME_FILE="$HOME/.tmux.theme.conf"

# Common base configuration for tmux-dotbar
echo "# $THEME Theme (via tmux-dotbar)" > "$THEME_FILE"
echo "set -g @plugin 'vaaleyard/tmux-dotbar'" >> "$THEME_FILE"

case "$THEME" in
    "catppuccin")
        echo "set -g @tmux-dotbar-bg '#1e1e2e'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg '#585b70'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-current '#cdd6f4'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-session '#9399b2'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-prefix '#cba6f7'" >> "$THEME_FILE"
        ;;
    "dracula")
        echo "set -g @tmux-dotbar-bg '#282a36'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg '#6272a4'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-current '#f8f8f2'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-session '#bd93f9'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-prefix '#ff79c6'" >> "$THEME_FILE"
        ;;
    "nord")
        echo "set -g @tmux-dotbar-bg '#2e3440'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg '#4c566a'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-current '#d8dee9'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-session '#88c0d0'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-prefix '#81a1c1'" >> "$THEME_FILE"
        ;;
    "rose-pine")
        echo "set -g @tmux-dotbar-bg '#191724'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg '#6e6a86'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-current '#e0def4'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-session '#c4a7e7'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-prefix '#eb6f92'" >> "$THEME_FILE"
        ;;
    "gruvbox")
        echo "set -g @tmux-dotbar-bg '#282828'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg '#a89984'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-current '#ebdbb2'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-session '#d79921'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-prefix '#cc241d'" >> "$THEME_FILE"
        ;;
    "tokyo-night")
        echo "set -g @tmux-dotbar-bg '#1a1b26'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg '#565f89'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-current '#c0caf5'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-session '#7aa2f7'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-prefix '#bb9af7'" >> "$THEME_FILE"
        ;;
    "github-dark")
        echo "set -g @tmux-dotbar-bg '#0d1117'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg '#8b949e'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-current '#c9d1d9'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-session '#58a6ff'" >> "$THEME_FILE"
        echo "set -g @tmux-dotbar-fg-prefix '#d2a8ff'" >> "$THEME_FILE"
        ;;
    *)
        exit 1
        ;;
esac

# Source and install plugins silently
tmux source-file ~/.tmux.conf > /dev/null 2>&1
~/.tmux/plugins/tpm/bin/install_plugins > /dev/null 2>&1

# Clear status line to avoid artifacts and reload
tmux set-option -g status-style bg=default,fg=default
tmux source-file ~/.tmux.conf > /dev/null 2>&1

# Show a brief non-intrusive notification
tmux display-message "Theme switched to $THEME"