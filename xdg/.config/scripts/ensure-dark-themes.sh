#!/bin/bash

# Ensure All Themes Stay in Dark Mode
# This script ensures that only Catppuccin Mocha can be light, all others stay dark

echo "🌙 Ensuring all themes stay in dark mode..."

# Set waybar to use dark theme (Tokyo Night)
echo "Tokyo Night" > /home/seb/dotfiles/.config/waybar/current-theme

# Ensure GTK uses dark theme for non-Catppuccin applications
gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Mocha-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Update cursor theme (keep mcmojave-cursors)
gsettings set org.gnome.desktop.interface cursor-theme 'mcmojave-cursors'
gsettings set org.gnome.desktop.interface cursor-size 24

# Generate dark mode colors using matugen
matugen color hex "#1e1e2e" --mode dark --type scheme-tonal-spot -c /home/seb/dotfiles/.config/matugen/config.toml

# Reload Hyprland colors
hyprctl reload

echo "✅ All themes set to dark mode!"
echo "🎨 Colors: Dark Catppuccin Mocha"
echo "🖱️  Cursor: mcmojave-cursors"
echo "📊 Waybar: Dark theme (Tokyo Night)"
echo "🔄 Restart applications to see full changes"
