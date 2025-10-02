#!/bin/bash

# Test script for walker theme switching
# This script allows you to test different walker themes

WALKER_THEMES=(
    "default"
    "tokyo-night"
    "catppuccin-mocha"
    "nord"
    "palenight"
    "ayu"
    "dracula"
)

# Function to apply walker theme
apply_walker_theme() {
    local walker_theme="$1"
    local walker_config="$HOME/.config/walker/config.toml"
    
    if [[ -z "$walker_theme" ]]; then
        echo "Error: No walker theme specified"
        return 1
    fi
    
    echo "Applying walker theme: $walker_theme"
    
    # Update walker config to use the new theme
    if [[ -f "$walker_config" ]]; then
        # Use sed to replace the theme line
        sed -i "s/theme = \".*\"/theme = \"$walker_theme\"/" "$walker_config"
        echo "Walker theme updated to: $walker_theme"
        echo "You can now test walker with the new theme"
    else
        echo "Error: Walker config not found: $walker_config"
        return 1
    fi
}

# Function to show theme switcher
show_theme_switcher() {
    echo "Available Walker Themes:"
    for i in "${!WALKER_THEMES[@]}"; do
        echo "$((i+1)). ${WALKER_THEMES[$i]}"
    done
    
    echo ""
    read -p "Enter theme number (1-${#WALKER_THEMES[@]}): " choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "${#WALKER_THEMES[@]}" ]]; then
        local selected_theme="${WALKER_THEMES[$((choice-1))]}"
        apply_walker_theme "$selected_theme"
    else
        echo "Invalid selection"
        exit 1
    fi
}

# Main execution
case "${1:-}" in
    "apply")
        if [[ -n "$2" ]]; then
            apply_walker_theme "$2"
        else
            echo "Usage: $0 apply <theme_name>"
            exit 1
        fi
        ;;
    "list")
        printf '%s\n' "${WALKER_THEMES[@]}"
        ;;
    *)
        show_theme_switcher
        ;;
esac
