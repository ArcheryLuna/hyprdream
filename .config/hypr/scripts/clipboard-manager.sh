#!/bin/bash

# Simple Clipboard Manager for Hyprland
# Alternative to cliphist using basic clipboard operations

CLIPBOARD_HISTORY_FILE="$HOME/.cache/clipboard_history"
MAX_ENTRIES=50

# Create cache directory if it doesn't exist
mkdir -p "$(dirname "$CLIPBOARD_HISTORY_FILE")"

# Function to show current clipboard content
show_current_clipboard() {
    echo "Current Clipboard Content:"
    echo "=============================="
    
    # Check if clipboard has content
    if wl-paste --list-types &>/dev/null; then
        # Show text content if available
        if wl-paste --list-types | grep -q "text/plain"; then
            echo "Text content:"
            wl-paste | head -3
            echo ""
        fi
        
        # Show image info if available
        if wl-paste --list-types | grep -q "image"; then
            echo "Image content detected"
            echo "Types: $(wl-paste --list-types | grep image | head -2)"
            echo ""
        fi
    else
        echo "No clipboard content available"
    fi
}

# Function to save current clipboard to history
save_to_history() {
    if wl-paste --list-types | grep -q "text/plain" 2>/dev/null; then
        local content=$(wl-paste 2>/dev/null)
        if [[ -n "$content" ]]; then
            # Add timestamp and content
            echo "$(date '+%Y-%m-%d %H:%M:%S') | $content" >> "$CLIPBOARD_HISTORY_FILE"
            
            # Keep only last MAX_ENTRIES
            if [[ -f "$CLIPBOARD_HISTORY_FILE" ]]; then
                tail -n "$MAX_ENTRIES" "$CLIPBOARD_HISTORY_FILE" > "${CLIPBOARD_HISTORY_FILE}.tmp"
                mv "${CLIPBOARD_HISTORY_FILE}.tmp" "$CLIPBOARD_HISTORY_FILE"
            fi
        fi
    fi
}

# Function to show clipboard history with walker
show_history_walker() {
    if [[ ! -f "$CLIPBOARD_HISTORY_FILE" ]]; then
        notify-send "Clipboard History" "No clipboard history found"
        return 1
    fi
    
    # Format history for walker and let user select
    local selected=$(tac "$CLIPBOARD_HISTORY_FILE" | walker --dmenu)
    
    if [[ -n "$selected" ]]; then
        # Extract content (everything after the " | ")
        local content="${selected#* | }"
        echo -n "$content" | wl-copy
        notify-send "Clipboard" "Item copied to clipboard"
    fi
}

# Function to show clipboard history with simple menu
show_history_simple() {
    if [[ ! -f "$CLIPBOARD_HISTORY_FILE" ]]; then
        echo "No clipboard history found"
        return 1
    fi
    
    echo "Clipboard History (most recent first):"
    echo "========================================"
    
    local count=1
    while IFS= read -r line; do
        local timestamp="${line%% | *}"
        local content="${line#* | }"
        echo "$count) [$timestamp] ${content:0:60}$([ ${#content} -gt 60 ] && echo '...')"
        ((count++))
    done < <(tac "$CLIPBOARD_HISTORY_FILE" | head -10)
    
    echo ""
    read -p "Enter number to copy (or Enter to cancel): " choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]]; then
        local selected_line=$(tac "$CLIPBOARD_HISTORY_FILE" | sed -n "${choice}p")
        if [[ -n "$selected_line" ]]; then
            local content="${selected_line#* | }"
            echo -n "$content" | wl-copy
            echo "✅ Copied to clipboard: ${content:0:50}$([ ${#content} -gt 50 ] && echo '...')"
        else
            echo "❌ Invalid selection"
        fi
    fi
}

# Function to clear clipboard history
clear_history() {
    if [[ -f "$CLIPBOARD_HISTORY_FILE" ]]; then
        rm "$CLIPBOARD_HISTORY_FILE"
        echo "✅ Clipboard history cleared"
        notify-send "Clipboard History" "History cleared"
    else
        echo "No history to clear"
    fi
}

# Function to start clipboard monitoring (daemon mode)
start_monitoring() {
    echo "Starting clipboard monitoring..."
    local last_content=""
    
    while true; do
        if wl-paste --list-types | grep -q "text/plain" 2>/dev/null; then
            local current_content=$(wl-paste 2>/dev/null)
            if [[ -n "$current_content" && "$current_content" != "$last_content" ]]; then
                save_to_history
                last_content="$current_content"
            fi
        fi
        sleep 2
    done
}

# Show help
show_help() {
    cat << EOF
Simple Clipboard Manager for Hyprland

Usage: $0 [COMMAND]

COMMANDS:
    show        Show current clipboard content
    history     Show clipboard history (interactive)
    walker      Show clipboard history with walker menu
    save        Save current clipboard to history
    clear       Clear clipboard history
    monitor     Start clipboard monitoring (daemon mode)
    help        Show this help message

EXAMPLES:
    $0 show                    # Show current clipboard
    $0 walker                  # Show history with walker
    $0 history                 # Show history with simple menu
    $0 clear                   # Clear all history

KEYBINDING SETUP:
    Add to Hyprland binds.conf:
    bind = \$main_mod, V, exec, $0 walker

FILES:
    History stored in: $CLIPBOARD_HISTORY_FILE
    Max entries: $MAX_ENTRIES
EOF
}

# Parse command
case "${1:-show}" in
    "show")
        show_current_clipboard
        ;;
    "history")
        show_history_simple
        ;;
    "walker")
        show_history_walker
        ;;
    "save")
        save_to_history
        echo "✅ Current clipboard saved to history"
        ;;
    "clear")
        clear_history
        ;;
    "monitor")
        start_monitoring
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
