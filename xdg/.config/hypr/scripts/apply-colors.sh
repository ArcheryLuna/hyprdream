#!/bin/bash

# Apply matugen colors to Hyprland configuration
# This script updates the animations.conf file with dynamic colors

COLORS_FILE="$HOME/.cache/matugen/colors-hyprland.conf"
ANIMATIONS_FILE="$HOME/.config/hypr/defaults/animations.conf"

# Source the colors file to get the color values
if [[ -f "$COLORS_FILE" ]]; then
    # Extract color values from the file
    color0=$(grep '^\$color0' "$COLORS_FILE" | cut -d'=' -f2 | tr -d ' #')
    color1=$(grep '^\$color1' "$COLORS_FILE" | cut -d'=' -f2 | tr -d ' #')
    color2=$(grep '^\$color2' "$COLORS_FILE" | cut -d'=' -f2 | tr -d ' #')
    color5=$(grep '^\$color5' "$COLORS_FILE" | cut -d'=' -f2 | tr -d ' #')
    
    # Update the animations.conf file with the extracted colors
    sed -i "s/col.active_border = rgb([0-9a-fA-F]\{6\})/col.active_border = rgb($color1)/" "$ANIMATIONS_FILE"
    sed -i "s/col.inactive_border = rgb([0-9a-fA-F]\{6\})/col.inactive_border = rgb($color0)/" "$ANIMATIONS_FILE"
    sed -i "s/color = rgb([0-9a-fA-F]\{6\})/color = rgb($color5)/" "$ANIMATIONS_FILE"
    
    echo "Applied colors to Hyprland configuration"
    
    # Reload Hyprland
    if command -v hyprctl &> /dev/null; then
        hyprctl reload
        echo "Hyprland configuration reloaded"
    fi
else
    echo "Colors file not found: $COLORS_FILE"
    exit 1
fi