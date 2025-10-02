#!/bin/bash

# Light Mode Theme Switcher
# Switches ONLY Catppuccin Mocha to Light mode, keeps all other themes in dark mode

echo "🌅 Switching to Light Mode (Catppuccin Mocha only)..."

# Generate light mode colors using matugen for Catppuccin Mocha
matugen color hex "#1e1e2e" --mode light --type scheme-tonal-spot -c /home/seb/dotfiles/.config/matugen/config.toml

# Update GTK theme to MatugenDynamic (generated from light colors)
gsettings set org.gnome.desktop.interface gtk-theme 'MatugenDynamic'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'

# Update cursor theme (keep mcmojave-cursors)
gsettings set org.gnome.desktop.interface cursor-theme 'mcmojave-cursors'
gsettings set org.gnome.desktop.interface cursor-size 24

# Ensure waybar uses dark theme (not light.css)
echo "Tokyo Night" > /home/seb/dotfiles/.config/waybar/current-theme

# Reload Hyprland colors
hyprctl reload

echo "✅ Light mode applied successfully!"
echo "🎨 Colors: Light Catppuccin Mocha (other themes remain dark)"
echo "🖱️  Cursor: mcmojave-cursors"
echo "📊 Waybar: Dark theme (Tokyo Night)"
echo "🔄 Restart applications to see full changes"
