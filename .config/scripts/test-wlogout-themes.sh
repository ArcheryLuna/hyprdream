#!/bin/bash

# Test script for wlogout theme switching
# This script allows you to test different wlogout themes

WLOGOUT_THEMES=(
    "tokyo-night"
    "catppuccin-mocha"
    "nord"
    "palenight"
    "ayu"
    "dracula"
)

# Function to apply wlogout theme
apply_wlogout_theme() {
    local wlogout_theme="$1"
    local wlogout_style="$HOME/.config/wlogout/style.css"
    local wlogout_themes_dir="$HOME/.config/wlogout/themes"
    
    if [[ -z "$wlogout_theme" ]]; then
        echo "Error: No wlogout theme specified"
        return 1
    fi
    
    echo "Applying wlogout theme: $wlogout_theme"
    
    # Copy theme to main style file
    local theme_path="$wlogout_themes_dir/$wlogout_theme.css"
    
    if [[ -f "$theme_path" ]]; then
        cp "$theme_path" "$wlogout_style"
        echo "Wlogout theme updated to: $wlogout_theme"
        echo "You can now test wlogout with the new theme"
    else
        echo "Error: Wlogout theme file not found: $theme_path"
        return 1
    fi
}

# Function to show theme switcher
show_theme_switcher() {
    echo "Available Wlogout Themes:"
    for i in "${!WLOGOUT_THEMES[@]}"; do
        echo "$((i+1)). ${WLOGOUT_THEMES[$i]}"
    done
    
    echo ""
    read -p "Enter theme number (1-${#WLOGOUT_THEMES[@]}): " choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "${#WLOGOUT_THEMES[@]}" ]]; then
        local selected_theme="${WLOGOUT_THEMES[$((choice-1))]}"
        apply_wlogout_theme "$selected_theme"
    else
        echo "Invalid selection"
        exit 1
    fi
}

# Function to test wlogout
test_wlogout() {
    echo "Testing wlogout with current theme..."
    wlogout
}

# Main execution
case "${1:-}" in
    "apply")
        if [[ -n "$2" ]]; then
            apply_wlogout_theme "$2"
        else
            echo "Usage: $0 apply <theme_name>"
            exit 1
        fi
        ;;
    "test")
        test_wlogout
        ;;
    "list")
        printf '%s\n' "${WLOGOUT_THEMES[@]}"
        ;;
    *)
        show_theme_switcher
        ;;
esac
