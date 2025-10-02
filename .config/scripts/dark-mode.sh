#!/bin/bash

# Dark Mode Theme Switcher
# Switches ALL themes to Dark mode

echo "🌙 Switching to Dark Mode (all themes)..."

# Generate dark mode colors using matugen
matugen color hex "#1e1e2e" --mode dark --type scheme-tonal-spot -c /home/seb/dotfiles/.config/matugen/config.toml

# Update GTK theme to MatugenDynamic (generated from dark colors)
gsettings set org.gnome.desktop.interface gtk-theme 'MatugenDynamic'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Update cursor theme (keep mcmojave-cursors)
gsettings set org.gnome.desktop.interface cursor-theme 'mcmojave-cursors'
gsettings set org.gnome.desktop.interface cursor-size 24

# Ensure waybar uses dark theme
echo "Tokyo Night" > /home/seb/dotfiles/.config/waybar/current-theme

# Reload Hyprland colors
hyprctl reload

echo "✅ Dark mode applied successfully!"
echo "🎨 Colors: Dark Catppuccin Mocha"
echo "🖱️  Cursor: mcmojave-cursors"
echo "📊 Waybar: Dark theme (Tokyo Night)"
echo "🔄 Restart applications to see full changes"
