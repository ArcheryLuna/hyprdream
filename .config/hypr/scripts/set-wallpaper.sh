#!/bin/bash

# Set wallpaper and generate matugen colors
# Usage: set-wallpaper.sh <wallpaper_path>

WALLPAPER="$1"

if [[ -z "$WALLPAPER" ]]; then
    echo "Usage: $0 <wallpaper_path>"
    exit 1
fi

if [[ ! -f "$WALLPAPER" ]]; then
    echo "Wallpaper not found: $WALLPAPER"
    exit 1
fi

# Set wallpaper using SWWW
if command -v swww &> /dev/null; then
    echo "Setting wallpaper with SWWW: $WALLPAPER"
    swww img "$WALLPAPER" --transition-type wipe --transition-duration 1
else
    echo "SWWW not found, please install swww"
    exit 1
fi

# Generate matugen colors from wallpaper
echo "Generating colors from wallpaper..."
"$HOME/.config/hypr/scripts/matugen-colors.sh" generate "$WALLPAPER"

echo "Wallpaper and colors applied successfully!"
