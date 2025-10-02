#!/bin/bash

# Theme switcher script using walker in dmenu mode
# This script allows switching between different Waybar themes

THEMES_DIR="$HOME/.config/waybar/themes"
CURRENT_THEME_FILE="$HOME/.config/waybar/current-theme"
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"

# Available themes
THEMES=(
    "Tokyo Night"
    "Catppuccin Mocha"
    "Nord"
    "Palenight"
    "Ayu"
    "Dracula"
)

# Theme file mappings
declare -A THEME_FILES=(
    ["Tokyo Night"]="tokyo-night.css"
    ["Catppuccin Mocha"]="catppuccin-mocha.css"
    ["Nord"]="nord.css"
    ["Palenight"]="palenight.css"
    ["Ayu"]="ayu.css"
    ["Dracula"]="dracula.css"
)

# Function to get current theme
get_current_theme() {
    if [[ -f "$CURRENT_THEME_FILE" ]]; then
        cat "$CURRENT_THEME_FILE"
    else
        echo "Catppuccin Mocha"  # Default theme
    fi
}

# Function to get random SWWW transition
get_random_transition() {
    local transitions=("simple" "fade" "left" "right" "top" "bottom" "wipe" "grow" "outer" "wave")
    local random_index=$((RANDOM % ${#transitions[@]}))
    echo "${transitions[$random_index]}"
}

# Walker theme file mappings
declare -A WALKER_THEME_FILES=(
    ["Tokyo Night"]="tokyo-night"
    ["Catppuccin Mocha"]="catppuccin-mocha"
    ["Nord"]="nord"
    ["Palenight"]="palenight"
    ["Ayu"]="ayu"
    ["Dracula"]="dracula"
)

# GTK theme file mappings
declare -A GTK_THEME_FILES=(
    ["Tokyo Night"]="Tokyonight-Dark"
    ["Catppuccin Mocha"]="catppuccin-mocha-mauve-standard+default"
    ["Nord"]="Colloid-Green-Dark-Compact-Nord"
    ["Palenight"]="palenight"
    ["Ayu"]="Yaru-sage-dark"
    ["Dracula"]="Adwaita-dark"
)

# Wlogout theme file mappings
declare -A WLOGOUT_THEME_FILES=(
    ["Tokyo Night"]="tokyo-night"
    ["Catppuccin Mocha"]="catppuccin-mocha"
    ["Nord"]="nord"
    ["Palenight"]="palenight"
    ["Ayu"]="ayu"
    ["Dracula"]="dracula"
)

# Function to apply walker theme
apply_walker_theme() {
    local walker_theme="$1"
    local walker_config="$HOME/.config/walker/config.toml"
    
    if [[ -z "$walker_theme" ]]; then
        echo "Warning: No walker theme specified"
        return
    fi
    
    echo "Applying walker theme: $walker_theme"
    
    # Update walker config to use the new theme
    if [[ -f "$walker_config" ]]; then
        # Use sed to replace the theme line
        sed -i "s/theme = \".*\"/theme = \"$walker_theme\"/" "$walker_config"
        echo "Walker theme updated to: $walker_theme"
    else
        echo "Warning: Walker config not found: $walker_config"
    fi
}

# Function to apply GTK theme
apply_gtk_theme() {
    local gtk_theme="$1"
    
    if [[ -z "$gtk_theme" ]]; then
        echo "Warning: No GTK theme specified"
        return
    fi
    
    echo "Applying GTK theme: $gtk_theme"
    
    # Apply GTK theme using gsettings
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
        echo "GTK theme updated to: $gtk_theme"
    else
        echo "Warning: gsettings not found, cannot apply GTK theme"
    fi
}

# Function to apply wlogout theme
apply_wlogout_theme() {
    local wlogout_theme="$1"
    local wlogout_style="$HOME/.config/wlogout/style.css"
    local wlogout_themes_dir="$HOME/.config/wlogout/themes"
    
    if [[ -z "$wlogout_theme" ]]; then
        echo "Warning: No wlogout theme specified"
        return
    fi
    
    echo "Applying wlogout theme: $wlogout_theme"
    
    # Copy theme to main style file
    local theme_path="$wlogout_themes_dir/$wlogout_theme.css"
    
    if [[ -f "$theme_path" ]]; then
        cp "$theme_path" "$wlogout_style"
        echo "Wlogout theme updated to: $wlogout_theme"
    else
        echo "Warning: Wlogout theme file not found: $theme_path"
    fi
}

# Function to apply theme
apply_theme() {
    local theme_name="$1"
    local theme_file="${THEME_FILES[$theme_name]}"
    local walker_theme="${WALKER_THEME_FILES[$theme_name]}"
    local gtk_theme="${GTK_THEME_FILES[$theme_name]}"
    local wlogout_theme="${WLOGOUT_THEME_FILES[$theme_name]}"
    
    if [[ -z "$theme_file" ]]; then
        echo "Error: Unknown theme '$theme_name'"
        exit 1
    fi
    
    local theme_path="$THEMES_DIR/$theme_file"
    
    if [[ ! -f "$theme_path" ]]; then
        echo "Error: Theme file not found: $theme_path"
        exit 1
    fi
    
    # Save current theme
    echo "$theme_name" > "$CURRENT_THEME_FILE"
    
    # Copy theme to main style file
    cp "$theme_path" "$WAYBAR_STYLE"
    
    # Apply walker theme
    apply_walker_theme "$walker_theme"
    
    # Apply GTK theme
    apply_gtk_theme "$gtk_theme"
    
    # Apply wlogout theme
    apply_wlogout_theme "$wlogout_theme"
    
    # Restart waybar
    pkill waybar
    sleep 0.5
    waybar &
    
    # Apply Matugen colors if available
    apply_matugen_colors "$theme_name"
    
    # Generate and apply colors to Hyprland
    if [[ -f "$wallpaper" ]]; then
        "$HOME/.config/hypr/scripts/matugen-colors.sh" generate "$wallpaper"
        
        # Reload all kitty instances
        if command -v kitty &> /dev/null; then
            echo "Reloading all kitty instances..."
            kitty @ --to unix:/tmp/kitty-* reload-config 2>/dev/null || true
            # Alternative method if the above doesn't work
            pkill -USR1 kitty 2>/dev/null || true
            echo "Kitty instances reloaded"
        fi
        
        # Reload tmux configuration
        if command -v tmux &> /dev/null; then
            echo "Reloading tmux configuration..."
            tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null || true
            echo "Tmux configuration reloaded"
        fi
        
        # Update btop theme (btop will automatically reload)
        if [[ -f "$HOME/.config/btop/themes/matugen.theme" ]]; then
            echo "Btop theme updated (will reload automatically)"
        fi
    fi
    
    # Set wallpaper with SWWW if available
    if [[ -f "$wallpaper" ]] && command -v swww &> /dev/null; then
        local transition_type=$(get_random_transition)
        local duration=$((1 + RANDOM % 3))  # Random duration between 1-3 seconds
        echo "Setting wallpaper with SWWW: $wallpaper"
        echo "Using random transition: $transition_type (${duration}s)"
        swww img "$wallpaper" --transition-type "$transition_type" --transition-duration "$duration"
        echo "Wallpaper set successfully"
    elif [[ -f "$wallpaper" ]]; then
        echo "SWWW not found, but wallpaper exists: $wallpaper"
        echo "Please install swww for wallpaper switching"
    else
        echo "Wallpaper not found: $wallpaper"
        echo "Please add the wallpaper to ~/Wallpapers/"
    fi
    
    echo "Applied theme: $theme_name"
}

# Function to apply Matugen colors based on theme
apply_matugen_colors() {
    local theme_name="$1"
    
    # Check if matugen is available
    if ! command -v matugen &> /dev/null; then
        echo "Matugen not found, skipping color generation"
        return
    fi
    
    # Define wallpaper paths for each theme (you can customize these)
    declare -A THEME_WALLPAPERS=(
        ["Tokyo Night"]="$HOME/Wallpapers/Japan-Is-Beautiful.png"
        ["Catppuccin Mocha"]="$HOME/Wallpapers/catppucin-mocha.jpg"
        ["Nord"]="$HOME/Wallpapers/Nord-Wallpaper.jpg"
        ["Palenight"]="$HOME/Wallpapers/Tokyo-Night-Life.jpg"
        ["Ayu"]="$HOME/Wallpapers/the-mountains.jpg"
        ["Dracula"]="$HOME/Wallpapers/Dracula.png"
    )
    
    local wallpaper="${THEME_WALLPAPERS[$theme_name]}"
    
    if [[ -f "$wallpaper" ]]; then
        echo "Applying Matugen colors for $theme_name..."
        matugen image "$wallpaper" --json > /tmp/matugen_colors.json
        
        # Apply colors to Hyprland
        if command -v hyprctl &> /dev/null; then
            # Extract colors from matugen output and apply to Hyprland
            local primary=$(jq -r '.colors.primary' /tmp/matugen_colors.json 2>/dev/null || echo "#7aa2f7")
            local secondary=$(jq -r '.colors.secondary' /tmp/matugen_colors.json 2>/dev/null || echo "#9aa5ce")
            
            # Apply to Hyprland (you may need to adjust these based on your setup)
            hyprctl keyword general:col.active_border "$primary" 2>/dev/null || true
            hyprctl keyword general:col.inactive_border "$secondary" 2>/dev/null || true
        fi
        
        # Set wallpaper with SWWW
        if command -v swww &> /dev/null; then
            local transition_type=$(get_random_transition)
            local duration=$((1 + RANDOM % 3))  # Random duration between 1-3 seconds
            echo "Setting wallpaper with SWWW: $wallpaper"
            echo "Using random transition: $transition_type (${duration}s)"
            swww img "$wallpaper" --transition-type "$transition_type" --transition-duration "$duration"
        fi
        
        # Clean up
        rm -f /tmp/matugen_colors.json
    else
        echo "Wallpaper not found for $theme_name: $wallpaper"
        echo "You can set custom wallpapers by editing the THEME_WALLPAPERS array in this script"
    fi
}

# Function to show theme switcher
show_theme_switcher() {
    local current_theme=$(get_current_theme)
    
    # Create options with current theme marked
    local options=()
    for theme in "${THEMES[@]}"; do
        if [[ "$theme" == "$current_theme" ]]; then
            options+=("$theme (current)")
        else
            options+=("$theme")
        fi
    done
    
    # Use walker in dmenu mode to show theme selection
    local selected=$(printf '%s\n' "${options[@]}" | walker --dmenu --placeholder "Select Theme" --height 300)
    
    if [[ -n "$selected" ]]; then
        # Remove "(current)" suffix if present
        local theme_name="${selected% (current)}"
        apply_theme "$theme_name"
    fi
}

# Main execution
case "${1:-}" in
    "apply")
        if [[ -n "$2" ]]; then
            apply_theme "$2"
        else
            echo "Usage: $0 apply <theme_name>"
            exit 1
        fi
        ;;
    "current")
        get_current_theme
        ;;
    "list")
        printf '%s\n' "${THEMES[@]}"
        ;;
    *)
        show_theme_switcher
        ;;
esac
