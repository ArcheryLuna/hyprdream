#!/bin/bash

# FZF Color Update Script
# This script regenerates FZF colors using matugen from the current wallpaper

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if matugen is available
if ! command -v matugen &> /dev/null; then
    print_error "matugen is not installed or not in PATH"
    exit 1
fi

# Get current wallpaper from swww if available
get_current_wallpaper() {
    if command -v swww &> /dev/null; then
        # Try to get current wallpaper from swww
        local wallpaper=$(swww query 2>/dev/null | grep -o '/[^"]*\.\(jpg\|jpeg\|png\|webp\)' | head -1)
        if [[ -n "$wallpaper" && -f "$wallpaper" ]]; then
            echo "$wallpaper"
            return 0
        fi
    fi
    
    # Fallback: look for wallpapers in common directories
    local wallpaper_dirs=("$HOME/Wallpapers" "$HOME/Pictures/Wallpapers" "$HOME/.local/share/wallpapers")
    
    for dir in "${wallpaper_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            local wallpaper=$(find "$dir" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | head -1)
            if [[ -n "$wallpaper" ]]; then
                echo "$wallpaper"
                return 0
            fi
        fi
    done
    
    return 1
}

# Main function
main() {
    print_status "Updating FZF colors with matugen..."
    
    # Get wallpaper path
    local wallpaper=""
    if [[ -n "$1" ]]; then
        wallpaper="$1"
        if [[ ! -f "$wallpaper" ]]; then
            print_error "Wallpaper file not found: $wallpaper"
            exit 1
        fi
    else
        print_status "No wallpaper specified, trying to detect current wallpaper..."
        wallpaper=$(get_current_wallpaper)
        if [[ $? -ne 0 ]]; then
            print_error "Could not detect current wallpaper"
            print_status "Usage: $0 [wallpaper_path]"
            print_status "Example: $0 ~/Wallpapers/my-wallpaper.jpg"
            exit 1
        fi
    fi
    
    print_status "Using wallpaper: $wallpaper"
    
    # Create FZF config directory if it doesn't exist
    mkdir -p "$HOME/.config/fzf"
    
    # Generate colors using matugen
    print_status "Generating colors from wallpaper..."
    if matugen image "$wallpaper" &>/dev/null; then
        print_success "Colors generated successfully!"
        
        # Check if FZF colors were generated
        if [[ -f "$HOME/.config/fzf/colors.sh" ]]; then
            print_success "FZF colors updated at ~/.config/fzf/colors.sh"
            
            # Source the new colors in current shell if possible
            if [[ -n "$ZSH_VERSION" ]]; then
                print_status "Reloading FZF colors in current shell..."
                source "$HOME/.config/fzf/colors.sh" 2>/dev/null && \
                    print_success "FZF colors reloaded!" || \
                    print_warning "Could not reload FZF colors in current shell"
            fi
            
            print_status "FZF colors will be automatically loaded in new terminal sessions"
            print_status "To apply in current session, run: source ~/.config/fzf/colors.sh"
        else
            print_warning "FZF colors file was not generated"
            print_status "Check your matugen configuration at ~/.config/matugen/config.toml"
        fi
    else
        print_error "Failed to generate colors with matugen"
        exit 1
    fi
    
    print_success "FZF color update completed!"
}

# Show usage if help is requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "FZF Color Update Script"
    echo "Usage: $0 [wallpaper_path]"
    echo ""
    echo "This script uses matugen to generate FZF colors from a wallpaper."
    echo "If no wallpaper is specified, it tries to detect the current one."
    echo ""
    echo "Examples:"
    echo "  $0                                    # Auto-detect wallpaper"
    echo "  $0 ~/Wallpapers/my-wallpaper.jpg     # Use specific wallpaper"
    echo ""
    echo "The generated colors will be saved to ~/.config/fzf/colors.sh"
    echo "and automatically loaded in new terminal sessions."
    exit 0
fi

# Run main function
main "$@"
