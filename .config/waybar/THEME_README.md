# Hyprland Theme Switcher

This theme system allows you to switch between different Waybar themes using walker in dmenu mode, with Matugen integration for dynamic wallpaper-based colors.

## Features

- **6 Beautiful Themes**: Tokyo Night, Catppuccin Mocha, Nord, Palenight, Ayu, and Dracula
- **Walker Integration**: Uses walker in dmenu mode for theme selection
- **Matugen Support**: Dynamic color generation from wallpapers
- **Easy Switching**: Click the 🎨 icon in Waybar or use `Super+T` shortcut
- **Persistent Themes**: Your theme choice is saved and restored on restart

## Usage

### Theme Switching Methods

1. **Waybar Button**: Click the 🎨 icon in the Waybar
2. **Keyboard Shortcut**: Press `Super+T`
3. **Command Line**: 
   ```bash
   ~/.config/waybar/scripts/theme-switcher.sh
   ```

### Available Themes

- **Tokyo Night**: Dark blue theme with purple accents
- **Catppuccin Mocha**: Warm dark theme with pink accents
- **Nord**: Cool dark theme with blue and cyan accents
- **Palenight**: Dark theme with blue and purple accents
- **Ayu**: Dark theme with yellow and orange accents
- **Dracula**: Dark theme with purple and pink accents

## Configuration

### Setting Custom Wallpapers

Edit the `THEME_WALLPAPERS` array in `/home/seb/dotfiles/.config/waybar/scripts/theme-switcher.sh`:

```bash
declare -A THEME_WALLPAPERS=(
    ["Tokyo Night"]="$HOME/Wallpapers/tokyo-night.jpg"
    ["Catppuccin Mocha"]="$HOME/Wallpapers/catppuccin-mocha.jpg"
    # ... add your wallpaper paths
)
```

**Note**: The system expects wallpapers to be in `~/Wallpapers/` directory.

### Matugen Configuration

The Matugen configuration is located at `/home/seb/dotfiles/.config/matugen/config.toml`. You can customize:

- Color generation settings
- Output format
- Hyprland integration
- Theme-specific color mappings

## Installation Requirements

Make sure you have the following installed:

- `walker` - For the dmenu interface
- `matugen` - For dynamic color generation (required for full functionality)
- `jq` - For JSON processing (required for Matugen)
- `hyprctl` - For Hyprland integration
- `swww` or `hyprpaper` - For wallpaper management

## File Structure

```
~/.config/
├── waybar/
│   ├── themes/
│   │   ├── tokyo-night.css
│   │   ├── catppuccin-mocha.css
│   │   ├── nord.css
│   │   ├── palenight.css
│   │   ├── ayu.css
│   │   └── dracula.css
│   ├── scripts/
│   │   └── theme-switcher.sh
│   └── current-theme
├── matugen/
│   └── config.toml
└── hypr/
    └── scripts/
        └── init-theme.sh
```

## Troubleshooting

### Theme Not Applying
- Check if the theme file exists in `~/.config/waybar/themes/`
- Ensure the script has execute permissions: `chmod +x ~/.config/waybar/scripts/theme-switcher.sh`

### Matugen Not Working
- Verify Matugen is installed: `matugen --version`
- Check if wallpapers exist at the specified paths
- Ensure `jq` is installed for JSON processing

### Waybar Not Restarting
- Check if Waybar process is running: `pgrep waybar`
- Manually restart Waybar: `pkill waybar && waybar`

## Customization

### Adding New Themes

1. Create a new CSS file in `~/.config/waybar/themes/`
2. Add the theme to the `THEMES` array in `theme-switcher.sh`
3. Add the theme file mapping to `THEME_FILES`
4. Optionally add wallpaper mapping to `THEME_WALLPAPERS`

### Modifying Existing Themes

Edit the CSS files in `~/.config/waybar/themes/` to customize colors, fonts, and styling.

## Keyboard Shortcuts

- `Super+T`: Open theme switcher
- `Super+Shift+T`: Regenerate colors from current wallpaper
- `Super+W`: Select wallpaper with walker
- `Super+Shift+W`: Set random wallpaper
- `Super+Shift+B`: Restart Waybar
- `Super+R`: Open walker (general launcher)

## Additional Scripts

### Set Wallpaper with Color Generation
```bash
~/.config/hypr/scripts/set-wallpaper.sh /path/to/wallpaper.jpg
```

### Manual Color Management
```bash
# Generate colors from wallpaper
~/.config/hypr/scripts/matugen-colors.sh generate /path/to/wallpaper.jpg

# Apply current colors
~/.config/hypr/scripts/matugen-colors.sh apply

# Reload colors from current wallpaper
~/.config/hypr/scripts/matugen-colors.sh reload
```

## Support

If you encounter issues:

1. Check the script logs for error messages
2. Verify all dependencies are installed
3. Ensure file permissions are correct
4. Check that all theme files exist and are readable
