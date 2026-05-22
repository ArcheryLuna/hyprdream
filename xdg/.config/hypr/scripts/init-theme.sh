#!/bin/bash

# Initialize theme system on Hyprland startup
# This script sets up the initial theme and applies Matugen colors

THEME_FILE="$HOME/.config/waybar/current-theme"
DEFAULT_THEME="Catppuccin Mocha"

# Create theme file if it doesn't exist
if [[ ! -f "$THEME_FILE" ]]; then
    echo "$DEFAULT_THEME" > "$THEME_FILE"
fi

# Get current theme
CURRENT_THEME=$(cat "$THEME_FILE")

# Apply the theme
if [[ -n "$CURRENT_THEME" ]]; then
    echo "Initializing theme: $CURRENT_THEME"
    "$HOME/.config/waybar/scripts/theme-switcher.sh" apply "$CURRENT_THEME"
else
    echo "No theme set, using default: $DEFAULT_THEME"
    "$HOME/.config/waybar/scripts/theme-switcher.sh" apply "$DEFAULT_THEME"
fi

# Initialize matugen colors if no colors exist
if [[ ! -f "$HOME/.cache/matugen/colors-hyprland.conf" ]]; then
    echo "No matugen colors found, generating default colors..."
    # Create default colors file
    cat > "$HOME/.cache/matugen/colors-hyprland.conf" << 'EOF'
# Default matugen colors
$color0 = #1a1b26
$color1 = #7aa2f7
$color2 = #9aa5ce
$color3 = #7dcfff
$color4 = #bb9af7
$color5 = #c0caf5
$color6 = #9ece6a
$color7 = #e0af68
$color8 = #f7768e
$color9 = #7aa2f7
$color10 = #c0caf5
$color11 = #1a1b26
$color12 = #1a1b26
$color13 = #1a1b26
$color14 = #1a1b26
$color15 = #1a1b26
EOF
    echo "Default colors created successfully"
fi
