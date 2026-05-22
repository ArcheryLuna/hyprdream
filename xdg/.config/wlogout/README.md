# Wlogout Theme Integration

This directory contains wlogout themes that are integrated with the system theme switcher.

## Available Themes

- **tokyo-night** - Tokyo Night color scheme with blue accents
- **catppuccin-mocha** - Catppuccin Mocha color scheme with purple accents
- **nord** - Nord color scheme with blue-gray accents
- **palenight** - Palenight color scheme with blue accents
- **ayu** - Ayu color scheme with yellow accents
- **dracula** - Dracula color scheme with purple accents

## Theme Structure

Each theme includes:
- **Color scheme** - Matching the corresponding system theme
- **Background** - Theme-appropriate wallpaper
- **Button styling** - Rounded buttons with theme colors
- **Hover effects** - Interactive feedback with theme colors
- **Icons** - System logout icons with hover states

## Integration with Theme Switcher

The wlogout themes are automatically applied when using the theme switcher scripts:

- `/home/seb/dotfiles/.config/waybar/scripts/theme-switcher-v2.sh` - Main theme switcher
- `/home/seb/dotfiles/.config/waybar/scripts/theme-switcher.sh` - Alternative theme switcher

When a theme is applied, the following components are automatically updated:
- **Waybar theme** - Main desktop bar styling
- **Swaync theme** - Notification center styling  
- **Walker theme** - Application launcher styling
- **GTK theme** - GTK application styling
- **Wlogout theme** - Logout screen styling
- **Wallpaper** - Desktop background
- **Colors** - System-wide color scheme via matugen

## Manual Theme Switching

You can manually switch wlogout themes using:

```bash
# Test script for wlogout themes
/home/seb/dotfiles/.config/scripts/test-wlogout-themes.sh

# Test wlogout with current theme
/home/seb/dotfiles/.config/scripts/test-wlogout-themes.sh test

# Or directly apply a theme
/home/seb/dotfiles/.config/scripts/test-wlogout-themes.sh apply <theme_name>
```

## Configuration

The wlogout theme is controlled by the main style file `/home/seb/dotfiles/.config/wlogout/style.css`, which is automatically updated by the theme switcher.

## Features

- **Theme consistency** - Matches your current desktop theme perfectly
- **Background wallpapers** - Each theme uses its corresponding wallpaper
- **Interactive buttons** - Hover effects and visual feedback
- **System integration** - Seamlessly integrated with your theme switcher
- **Keyboard shortcuts** - All buttons have keyboard shortcuts (l, h, e, s, u, r)

## Usage

- **Launch wlogout**: `wlogout`
- **Keyboard shortcuts**:
  - `l` - Lock
  - `h` - Hibernate  
  - `e` - Logout
  - `s` - Shutdown
  - `u` - Suspend
  - `r` - Reboot

The wlogout interface will automatically match your current system theme and provide a cohesive user experience.
