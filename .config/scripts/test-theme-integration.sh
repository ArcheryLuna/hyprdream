#!/bin/bash

# Test script for theme integration between waybar and swaync
# This script tests the theme switcher functionality

THEME_SCRIPT="$HOME/.config/waybar/scripts/theme-switcher-v2.sh"

echo "Testing theme integration..."
echo "================================"

# Test 1: Check if theme script exists and is executable
if [[ -f "$THEME_SCRIPT" ]]; then
    echo "✓ Theme script found: $THEME_SCRIPT"
    if [[ -x "$THEME_SCRIPT" ]]; then
        echo "✓ Theme script is executable"
    else
        echo "✗ Theme script is not executable"
        chmod +x "$THEME_SCRIPT"
        echo "✓ Made theme script executable"
    fi
else
    echo "✗ Theme script not found: $THEME_SCRIPT"
    exit 1
fi

# Test 2: Check if swaync themes exist
echo ""
echo "Checking swaync themes..."
SWAYNC_THEMES_DIR="$HOME/.config/swaync/themes"
THEMES=("tokyo-night" "catppuccin-mocha" "nord" "palenight" "ayu" "dracula")

for theme in "${THEMES[@]}"; do
    theme_dir="$SWAYNC_THEMES_DIR/$theme"
    if [[ -d "$theme_dir" ]]; then
        if [[ -f "$theme_dir/notifications.css" ]] && [[ -f "$theme_dir/central_control.css" ]]; then
            echo "✓ $theme theme files found"
        else
            echo "✗ $theme theme files incomplete"
        fi
    else
        echo "✗ $theme theme directory not found"
    fi
done

# Test 3: Test theme script functionality
echo ""
echo "Testing theme script functionality..."

# Test list command
echo "Available themes:"
"$THEME_SCRIPT" list

# Test current theme
echo ""
echo "Current theme: $("$THEME_SCRIPT" current)"

# Test swaync theme switching
echo ""
echo "Testing swaync theme switching..."
"$THEME_SCRIPT" swaync

echo ""
echo "Theme integration test completed!"
echo "================================"
echo ""
echo "Usage examples:"
echo "  $THEME_SCRIPT                    # Show theme switcher menu"
echo "  $THEME_SCRIPT apply 'Tokyo Night' # Apply specific theme"
echo "  $THEME_SCRIPT swaync             # Switch swaync theme only"
echo "  $THEME_SCRIPT reload             # Reload colors from wallpaper"
