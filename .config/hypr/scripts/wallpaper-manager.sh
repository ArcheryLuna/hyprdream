#!/bin/bash

# Wallpaper manager script with SWWW and Matugen integration
# This script provides various wallpaper management functions

WALLPAPER_DIR="$HOME/Wallpapers"
CURRENT_WALLPAPER_FILE="$HOME/.cache/matugen/current-wallpaper"

# Function to set wallpaper with SWWW
set_wallpaper() {
    local wallpaper="$1"
    
    if [[ ! -f "$wallpaper" ]]; then
        echo "Wallpaper not found: $wallpaper"
        return 1
    fi
    
    echo "Setting wallpaper: $wallpaper"
    
    # Function to get random SWWW transition
    get_random_transition() {
        local transitions=("simple" "fade" "left" "right" "top" "bottom" "wipe" "grow" "outer" "wave")
        local random_index=$((RANDOM % ${#transitions[@]}))
        echo "${transitions[$random_index]}"
    }
    
    # Set wallpaper with SWWW
    local transition_type=$(get_random_transition)
    local duration=$((1 + RANDOM % 3))  # Random duration between 1-3 seconds
    echo "Using random transition: $transition_type (${duration}s)"
    swww img "$wallpaper" --transition-type "$transition_type" --transition-duration "$duration"
    
    # Save current wallpaper
    echo "$wallpaper" > "$CURRENT_WALLPAPER_FILE"
    
    # Generate colors from wallpaper
    echo "Generating colors from wallpaper..."
    "$HOME/.config/hypr/scripts/matugen-colors.sh" generate "$wallpaper"
    
    echo "Wallpaper and colors applied successfully!"
}

# Function to get random wallpaper
get_random_wallpaper() {
    if [[ -d "$WALLPAPER_DIR" ]]; then
        find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1
    else
        echo ""
    fi
}

# Function to set random wallpaper
set_random_wallpaper() {
    local random_wallpaper=$(get_random_wallpaper)
    
    if [[ -n "$random_wallpaper" ]]; then
        set_wallpaper "$random_wallpaper"
    else
        echo "No wallpapers found in $WALLPAPER_DIR"
        echo "Please add wallpapers to $WALLPAPER_DIR"
        return 1
    fi
}

# Function to list available wallpapers
list_wallpapers() {
    if [[ -d "$WALLPAPER_DIR" ]]; then
        echo "Available wallpapers:"
        find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | sort
    else
        echo "Wallpaper directory not found: $WALLPAPER_DIR"
        echo "Please create the directory and add wallpapers"
    fi
}

# Function to show current wallpaper
show_current_wallpaper() {
    if [[ -f "$CURRENT_WALLPAPER_FILE" ]]; then
        cat "$CURRENT_WALLPAPER_FILE"
    else
        echo "No current wallpaper recorded"
    fi
}

# Function to set wallpaper from walker selection
select_wallpaper() {
    if [[ ! -d "$WALLPAPER_DIR" ]]; then
        echo "Wallpaper directory not found: $WALLPAPER_DIR"
        return 1
    fi
    
    # Get list of wallpapers
    local wallpapers=($(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | sort))
    
    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        echo "No wallpapers found in $WALLPAPER_DIR"
        return 1
    fi
    
    # Use walker to select wallpaper
    local selected=$(printf '%s\n' "${wallpapers[@]}" | walker --dmenu --placeholder "Select Wallpaper" --height 400)
    
    if [[ -n "$selected" ]]; then
        set_wallpaper "$selected"
    fi
}

# Function to set wallpaper for specific theme
set_theme_wallpaper() {
    local theme="$1"
    
    # Define theme wallpapers
    declare -A THEME_WALLPAPERS=(
        ["Tokyo Night"]="$WALLPAPER_DIR/Tokyo-Night-Life.jpg"
        ["Catppuccin Mocha"]="$WALLPAPER_DIR/catppucin-mocha.jpg"
        ["Nord"]="$WALLPAPER_DIR/Nord-Wallpaper.jpg"
        ["Palenight"]="$WALLPAPER_DIR/Japan-Is-Beautiful.png"
        ["Ayu"]="$WALLPAPER_DIR/the-mountains.jpg"
        ["Dracula"]="$WALLPAPER_DIR/Tokyo-Night-Life.jpg"
    )
    
    local wallpaper="${THEME_WALLPAPERS[$theme]}"
    
    if [[ -n "$wallpaper" && -f "$wallpaper" ]]; then
        set_wallpaper "$wallpaper"
    else
        echo "Theme wallpaper not found for $theme: $wallpaper"
        echo "Please add the wallpaper to $WALLPAPER_DIR"
        return 1
    fi
}

# Main execution
case "${1:-}" in
    "set")
        if [[ -n "$2" ]]; then
            set_wallpaper "$2"
        else
            echo "Usage: $0 set <wallpaper_path>"
            exit 1
        fi
        ;;
    "random")
        set_random_wallpaper
        ;;
    "list")
        list_wallpapers
        ;;
    "current")
        show_current_wallpaper
        ;;
    "select")
        select_wallpaper
        ;;
    "theme")
        if [[ -n "$2" ]]; then
            set_theme_wallpaper "$2"
        else
            echo "Usage: $0 theme <theme_name>"
            exit 1
        fi
        ;;
    *)
        echo "Wallpaper Manager for SWWW"
        echo ""
        echo "Usage: $0 {set|random|list|current|select|theme}"
        echo ""
        echo "Commands:"
        echo "  set <path>     - Set specific wallpaper"
        echo "  random         - Set random wallpaper"
        echo "  list           - List available wallpapers"
        echo "  current        - Show current wallpaper"
        echo "  select         - Select wallpaper with walker"
        echo "  theme <name>   - Set wallpaper for theme"
        echo ""
        echo "Examples:"
        echo "  $0 set ~/Pictures/wallpaper.jpg"
        echo "  $0 random"
        echo "  $0 select"
        echo "  $0 theme 'Tokyo Night'"
        exit 1
        ;;
esac
