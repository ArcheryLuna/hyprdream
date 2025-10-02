# Walker Theme Integration

This directory contains walker themes that are integrated with the system theme switcher.

## Available Themes

- **default** - Original walker theme
- **tokyo-night** - Tokyo Night color scheme
- **catppuccin-mocha** - Catppuccin Mocha color scheme  
- **nord** - Nord color scheme
- **palenight** - Palenight color scheme
- **ayu** - Ayu color scheme
- **dracula** - Dracula color scheme

## Theme Structure

Each theme directory contains:
- `style.css` - Main theme stylesheet with color definitions
- `layout.xml` - Main layout structure
- `item.xml` - Item layout template
- Various `item_*.xml` files for different provider types

## Integration with Theme Switcher

The walker themes are automatically applied when using the theme switcher scripts:

- `/home/seb/dotfiles/.config/waybar/scripts/theme-switcher-v2.sh` - Main theme switcher
- `/home/seb/dotfiles/.config/waybar/scripts/theme-switcher.sh` - Alternative theme switcher

When a theme is applied, the following components are automatically updated:
- **Waybar theme** - Main desktop bar styling
- **Swaync theme** - Notification center styling  
- **Walker theme** - Application launcher styling
- **GTK theme** - GTK application styling
- **Wallpaper** - Desktop background
- **Colors** - System-wide color scheme via matugen

## GTK Theme Mappings

The following GTK themes are applied for each system theme:

- **Tokyo Night** → `Tokyonight-Dark`
- **Catppuccin Mocha** → `catppuccin-mocha-mauve-standard+default`
- **Nord** → `Colloid-Green-Dark-Compact-Nord`
- **Palenight** → `palenight`
- **Ayu** → `Yaru-sage-dark`
- **Dracula** → `Adwaita-dark`

## Manual Theme Switching

You can manually switch themes using:

```bash
# Test script for walker themes
/home/seb/dotfiles/.config/scripts/test-walker-themes.sh

# Test script for GTK themes
/home/seb/dotfiles/.config/scripts/test-gtk-themes.sh

# Or directly apply a theme
/home/seb/dotfiles/.config/scripts/test-walker-themes.sh apply <theme_name>
/home/seb/dotfiles/.config/scripts/test-gtk-themes.sh apply <theme_name>
```

## Configuration

The walker theme is controlled by the `theme` setting in `/home/seb/dotfiles/.config/walker/config.toml`:

```toml
theme = "tokyo-night"  # Current theme
```

## Color Scheme Details

Each theme uses a consistent color scheme based on the corresponding waybar theme:

- **Background**: Dark background matching the waybar theme
- **Accent**: Primary accent color from the waybar theme  
- **Text**: Foreground text color from the waybar theme
- **Hover/Selection**: Semi-transparent accent color for interactive elements

The themes maintain visual consistency with the rest of the desktop environment while providing a cohesive user experience.
