#!/bin/bash

# Theme Status Checker
# Shows current theme configuration

echo "🎨 Current Theme Status:"
echo "========================="

# Check current waybar theme
if [[ -f "/home/seb/dotfiles/.config/waybar/current-theme" ]]; then
    WAYBAR_THEME=$(cat /home/seb/dotfiles/.config/waybar/current-theme)
    echo "📊 Waybar Theme: $WAYBAR_THEME"
else
    echo "📊 Waybar Theme: Not set"
fi

# Check GTK theme
GTK_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
echo "🖼️  GTK Theme: $GTK_THEME"

# Check color scheme
COLOR_SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")
echo "🎨 Color Scheme: $COLOR_SCHEME"

# Check cursor theme
CURSOR_THEME=$(gsettings get org.gnome.desktop.interface cursor-theme | tr -d "'")
echo "🖱️  Cursor Theme: $CURSOR_THEME"

# Check if light.css is being used
if [[ "$WAYBAR_THEME" == "light" ]]; then
    echo "⚠️  WARNING: Light waybar theme detected!"
    echo "   Run: /home/seb/dotfiles/.config/scripts/ensure-dark-themes.sh"
else
    echo "✅ All themes are in dark mode"
fi

echo ""
echo "Available theme switching commands:"
echo "🌅 Light Mode (Catppuccin only): /home/seb/dotfiles/.config/scripts/light-mode.sh"
echo "🌙 Dark Mode (all themes): /home/seb/dotfiles/.config/scripts/dark-mode.sh"
echo "🔧 Force Dark (ensure all dark): /home/seb/dotfiles/.config/scripts/ensure-dark-themes.sh"
