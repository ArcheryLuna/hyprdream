#!/bin/bash

# Apply Matugen Dynamic Themes
# This script applies the MatugenDynamic theme to GTK and Qt applications

echo "🎨 Applying MatugenDynamic themes..."

# Apply GTK theme
gsettings set org.gnome.desktop.interface gtk-theme 'MatugenDynamic'

# Apply Qt5 theme
export QT_QPA_PLATFORMTHEME=qt5ct

# Apply Qt6 theme  
export QT_QPA_PLATFORMTHEME=qt6ct

# Reload Hyprland colors
hyprctl reload

echo "✅ MatugenDynamic themes applied!"
echo "🖼️  GTK Theme: MatugenDynamic"
echo "🎨 Qt Theme: MatugenDynamic color scheme"
echo "🔄 Restart applications to see full changes"
