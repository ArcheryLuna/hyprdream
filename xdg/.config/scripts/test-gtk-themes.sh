#!/bin/bash

# Test script for GTK theme switching
# This script allows you to test different GTK themes

GTK_THEMES=(
    "Adwaita-dark"
    "Tokyonight-Dark"
    "catppuccin-mocha-mauve-standard+default"
    "catppuccin-mocha-blue-standard+default"
    "catppuccin-mocha-green-standard+default"
    "catppuccin-mocha-lavender-standard+default"
    "Colloid-Green-Dark-Compact-Nord"
    "Yaru-sage-dark"
    "palenight"
)

# Function to apply GTK theme
apply_gtk_theme() {
    local gtk_theme="$1"
    
    if [[ -z "$gtk_theme" ]]; then
        echo "Error: No GTK theme specified"
        return 1
    fi
    
    echo "Applying GTK theme: $gtk_theme"
    
    # Apply GTK theme using gsettings
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
        echo "GTK theme updated to: $gtk_theme"
        echo "You can now test GTK applications with the new theme"
    else
        echo "Error: gsettings not found"
        return 1
    fi
}

# Function to show theme switcher
show_theme_switcher() {
    echo "Available GTK Themes:"
    for i in "${!GTK_THEMES[@]}"; do
        echo "$((i+1)). ${GTK_THEMES[$i]}"
    done
    
    echo ""
    read -p "Enter theme number (1-${#GTK_THEMES[@]}): " choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "${#GTK_THEMES[@]}" ]]; then
        local selected_theme="${GTK_THEMES[$((choice-1))]}"
        apply_gtk_theme "$selected_theme"
    else
        echo "Invalid selection"
        exit 1
    fi
}

# Function to show current GTK theme
show_current_theme() {
    if command -v gsettings &> /dev/null; then
        local current_theme=$(gsettings get org.gnome.desktop.interface gtk-theme)
        echo "Current GTK theme: $current_theme"
    else
        echo "gsettings not found"
    fi
}

# Main execution
case "${1:-}" in
    "apply")
        if [[ -n "$2" ]]; then
            apply_gtk_theme "$2"
        else
            echo "Usage: $0 apply <theme_name>"
            exit 1
        fi
        ;;
    "current")
        show_current_theme
        ;;
    "list")
        printf '%s\n' "${GTK_THEMES[@]}"
        ;;
    *)
        show_theme_switcher
        ;;
esac
