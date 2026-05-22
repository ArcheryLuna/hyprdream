#!/bin/bash

# Enhanced Screenshot Script for Hyprland
# Supports multiple screenshot modes with notifications and clipboard integration

# Configuration
SCREENSHOT_DIR="$HOME/screenshots"
TEMP_DIR="/tmp"
DATE_FORMAT="%Y-%m-%d_%H-%M-%S"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create screenshots directory if it doesn't exist
mkdir -p "$SCREENSHOT_DIR"

# Function to send notification
notify_user() {
    local title="$1"
    local message="$2"
    local icon="$3"
    local urgency="${4:-normal}"
    
    if command -v notify-send &> /dev/null; then
        notify-send -u "$urgency" -i "$icon" "$title" "$message"
    else
        echo -e "${GREEN}[SCREENSHOT]${NC} $title: $message"
    fi
}

# Function to copy to clipboard
copy_to_clipboard() {
    local file="$1"
    if [[ -f "$file" ]]; then
        wl-copy < "$file"
        echo "Screenshot copied to clipboard"
    fi
}

# Function to open screenshot
open_screenshot() {
    local file="$1"
    if [[ -f "$file" ]]; then
        if command -v gpicview &> /dev/null; then
            gpicview "$file" &
        elif command -v eog &> /dev/null; then
            eog "$file" &
        elif command -v feh &> /dev/null; then
            feh "$file" &
        else
            echo "No image viewer found"
        fi
    fi
}

# Function to take screenshot with grim/slurp (more reliable)
take_screenshot_grim() {
    local mode="$1"
    local filename="$2"
    
    case "$mode" in
        "region")
            grim -g "$(slurp)" "$filename"
            ;;
        "window")
            # Get focused window geometry
            local window_geometry=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
            if [[ "$window_geometry" != "null" ]]; then
                grim -g "$window_geometry" "$filename"
            else
                echo "No active window found"
                return 1
            fi
            ;;
        "fullscreen")
            grim "$filename"
            ;;
        "monitor")
            # Let user select monitor
            local monitor=$(slurp -o)
            if [[ -n "$monitor" ]]; then
                grim -o "$monitor" "$filename"
            else
                echo "No monitor selected"
                return 1
            fi
            ;;
        *)
            echo "Unknown mode: $mode"
            return 1
            ;;
    esac
}

# Function to take screenshot with hyprshot (fallback)
take_screenshot_hyprshot() {
    local mode="$1"
    local filename="$2"
    
    case "$mode" in
        "region")
            hyprshot -m region -o "$SCREENSHOT_DIR" --filename "$(basename "$filename")"
            ;;
        "window")
            hyprshot -m window -o "$SCREENSHOT_DIR" --filename "$(basename "$filename")"
            ;;
        "fullscreen")
            hyprshot -m output -o "$SCREENSHOT_DIR" --filename "$(basename "$filename")"
            ;;
        *)
            echo "Hyprshot mode not supported: $mode"
            return 1
            ;;
    esac
}

# Main screenshot function
take_screenshot() {
    local mode="$1"
    local copy_clipboard="${2:-true}"
    local open_after="${3:-false}"
    local save_file="${4:-true}"
    
    # Generate filename
    local timestamp=$(date +"$DATE_FORMAT")
    local filename="$SCREENSHOT_DIR/screenshot_${mode}_${timestamp}.png"
    
    echo "Taking $mode screenshot..."
    
    # Try grim first (more reliable), fallback to hyprshot
    if command -v grim &> /dev/null && command -v slurp &> /dev/null; then
        if take_screenshot_grim "$mode" "$filename"; then
            echo "Screenshot taken with grim: $filename"
        else
            echo "Grim failed, trying hyprshot..."
            if take_screenshot_hyprshot "$mode" "$filename"; then
                echo "Screenshot taken with hyprshot: $filename"
            else
                notify_user "Screenshot Failed" "Could not take $mode screenshot" "dialog-error" "critical"
                return 1
            fi
        fi
    elif command -v hyprshot &> /dev/null; then
        if take_screenshot_hyprshot "$mode" "$filename"; then
            echo "Screenshot taken with hyprshot: $filename"
        else
            notify_user "Screenshot Failed" "Could not take $mode screenshot" "dialog-error" "critical"
            return 1
        fi
    else
        notify_user "Screenshot Failed" "No screenshot tool available" "dialog-error" "critical"
        return 1
    fi
    
    # Check if file was created and has content
    if [[ ! -f "$filename" ]] || [[ ! -s "$filename" ]]; then
        notify_user "Screenshot Failed" "Screenshot file is empty or missing" "dialog-error" "critical"
        return 1
    fi
    
    # Get file size for notification
    local file_size=$(du -h "$filename" | cut -f1)
    
    # Copy to clipboard if requested
    if [[ "$copy_clipboard" == "true" ]]; then
        copy_to_clipboard "$filename"
    fi
    
    # Open screenshot if requested
    if [[ "$open_after" == "true" ]]; then
        open_screenshot "$filename"
    fi
    
    # Send success notification
    local clipboard_text=""
    if [[ "$copy_clipboard" == "true" ]]; then
        clipboard_text=" (copied to clipboard)"
    fi
    
    notify_user "Screenshot Saved" "$(basename "$filename") ($file_size)$clipboard_text" "camera-photo" "normal"
    
    echo "Screenshot saved: $filename"
    return 0
}

# Interactive mode selection
interactive_mode() {
    echo "Screenshot Mode Selection:"
    echo "1) Region (select area)"
    echo "2) Window (active window)"
    echo "3) Fullscreen (entire screen)"
    echo "4) Monitor (select monitor)"
    echo "5) Cancel"
    
    read -p "Choose mode (1-5): " choice
    
    case "$choice" in
        1) take_screenshot "region" ;;
        2) take_screenshot "window" ;;
        3) take_screenshot "fullscreen" ;;
        4) take_screenshot "monitor" ;;
        5) echo "Cancelled"; exit 0 ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac
}

# Show help
show_help() {
    cat << EOF
Enhanced Screenshot Script for Hyprland

Usage: $0 [MODE] [OPTIONS]

MODES:
    region      Select a region to screenshot
    window      Screenshot the active window
    fullscreen  Screenshot the entire screen
    monitor     Select a monitor to screenshot
    interactive Show interactive mode selection

OPTIONS:
    --no-clipboard    Don't copy to clipboard
    --open           Open screenshot after taking
    --no-save        Don't save to file (clipboard only)
    --help           Show this help message

EXAMPLES:
    $0 region                    # Region screenshot (copied to clipboard)
    $0 window --open            # Window screenshot, open it, and copy to clipboard
    $0 fullscreen --no-clipboard # Fullscreen without clipboard (save only)
    $0 interactive              # Interactive mode selection

KEYBINDINGS (suggested):
    Super + Print           -> fullscreen
    Super + Shift + S       -> region
    Super + Shift + W       -> window
    Super + Shift + M       -> monitor
    Super + Shift + Print   -> interactive

FILES:
    Screenshots saved to: $SCREENSHOT_DIR
    Format: screenshot_[mode]_YYYY-MM-DD_HH-MM-SS.png

DEPENDENCIES:
    Required: wl-copy
    Primary: grim, slurp (recommended)
    Fallback: hyprshot
    Optional: swaync-client (for notifications)
EOF
}

# Parse command line arguments
MODE=""
COPY_CLIPBOARD="true"  # Always copy to clipboard by default
OPEN_AFTER="false"
SAVE_FILE="true"

while [[ $# -gt 0 ]]; do
    case $1 in
        region|window|fullscreen|monitor|interactive)
            MODE="$1"
            shift
            ;;
        --no-clipboard)
            COPY_CLIPBOARD="false"
            shift
            ;;
        --open)
            OPEN_AFTER="true"
            shift
            ;;
        --no-save)
            SAVE_FILE="false"
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Default to region if no mode specified
if [[ -z "$MODE" ]]; then
    MODE="region"
fi

# Force clipboard copying to always be true unless explicitly disabled
if [[ "$COPY_CLIPBOARD" != "false" ]]; then
    COPY_CLIPBOARD="true"
fi

# Execute based on mode
if [[ "$MODE" == "interactive" ]]; then
    interactive_mode
else
    take_screenshot "$MODE" "$COPY_CLIPBOARD" "$OPEN_AFTER" "$SAVE_FILE"
fi
