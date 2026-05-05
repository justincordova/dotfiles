#!/usr/bin/env bash

THEME="$1"
THEME_FILE="$HOME/.tmux.theme.conf"

# Jellybeans: static theme (no catppuccin plugin)
if [ "$THEME" = "jellybeans" ]; then
    cat > "$THEME_FILE" <<'JELLYBEANS'
# Jellybeans Theme (custom, no plugin)

bg_color="#121212"
fg_color="#dedede"
accent="#474e91"
cursor="#ffa560"
black="#929292"
red="#e27373"
green="#94b979"
yellow="#ffba7b"
blue="#97bedc"
magenta="#e1c0fa"
cyan="#00988e"
white="#dedede"
bright_black="#bdbdbd"
bright_red="#ffa1a1"
bright_green="#bddeab"
bright_yellow="#ffdca0"
bright_blue="#b1d8f6"
bright_magenta="#fbdaff"
bright_cyan="#1ab2a8"
bright_white="#ffffff"

set -g status-style "bg=${bg_color},fg=${fg_color}"
set -g status-justify left
set -g status-right-length 100
set -g status-left-length 100
set -g status-left ""
set -g status-right "#[fg=${bright_black},bg=${bg_color}] #S "
set -g window-status-format "#[fg=${white},bg=#1a1a1a] #I #[fg=${white},bg=${bg_color}] #W "
set -g window-status-current-format "#[fg=${bg_color},bg=${blue},bold] #I #[fg=${fg_color},bg=${accent}] #W "
set -g window-status-separator ""
set -g pane-border-style "fg=${bright_black}"
set -g pane-active-border-style "fg=${blue}"
set -g message-style "bg=${accent},fg=${fg_color}"
set -g mode-style "bg=${accent},fg=${fg_color}"
set -g clock-mode-colour "${blue}"
JELLYBEANS

    tmux source-file ~/.tmux.conf > /dev/null 2>&1
    tmux display-message "Theme switched to Jellybeans"
    exit 0
fi

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
