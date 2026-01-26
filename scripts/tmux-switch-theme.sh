#!/usr/bin/env bash

THEME="$1"
THEME_FILE="$HOME/.tmux.theme.conf"

# Start writing the theme configuration
echo "# $THEME Theme (via catppuccin/tmux)" > "$THEME_FILE"
echo "set -g @plugin 'catppuccin/tmux'" >> "$THEME_FILE"

# Common Styling & Layout Configuration
# Set Flavor first to ensure it loads correctly
case "$THEME" in
    "catppuccin")
        echo "set -g @catppuccin_flavor 'frappe'" >> "$THEME_FILE"
        ;;
    "dracula")
        echo "set -g @catppuccin_flavor 'mocha'" >> "$THEME_FILE" # Dark/Contrast
        ;;
    "nord")
        echo "set -g @catppuccin_flavor 'macchiato'" >> "$THEME_FILE" # Cooler/Muted
        ;;
    "rose-pine")
        echo "set -g @catppuccin_flavor 'mocha'" >> "$THEME_FILE"
        ;;
    "gruvbox")
        echo "set -g @catppuccin_flavor 'mocha'" >> "$THEME_FILE" # Warm/Dark
        ;;
    "tokyo-night")
        echo "set -g @catppuccin_flavor 'mocha'" >> "$THEME_FILE"
        ;;
    "github-dark")
        echo "set -g @catppuccin_flavor 'mocha'" >> "$THEME_FILE"
        ;;
    *)
        echo "set -g @catppuccin_flavor 'frappe'" >> "$THEME_FILE"
        ;;
esac

echo "set -g @catppuccin_window_status_style 'basic'" >> "$THEME_FILE"
echo "set -g @catppuccin_window_current_text ' #{window_name}'" >> "$THEME_FILE"
echo "set -g @catppuccin_window_text ' #{window_name}'" >> "$THEME_FILE"
echo "set -g @catppuccin_window_current_number_color \"#{ @thm_mauve}\"" >> "$THEME_FILE"
echo "set -g @catppuccin_window_number_color \"#{?window_zoomed_flag,#{ @thm_yellow},#{ @thm_overlay_2}}\"" >> "$THEME_FILE"

# Status Line Layout
echo "set -g status-right-length 100" >> "$THEME_FILE"
echo "set -g status-left-length 100" >> "$THEME_FILE"
echo "set -g status-left \"\"" >> "$THEME_FILE"
echo "set -g status-right \"#{E: @catppuccin_status_application}\"" >> "$THEME_FILE"
echo "set -ag status-right \"#{E: @catppuccin_status_session}\"" >> "$THEME_FILE"

# Set Flavor based on selection (Removed previous case statement block)

# Source and install plugins silently
tmux source-file ~/.tmux.conf > /dev/null 2>&1
~/.tmux/plugins/tpm/bin/install_plugins > /dev/null 2>&1

# Show a brief notification
tmux display-message "Theme switched to $THEME (mapped to Catppuccin flavor)"
