#!/bin/bash

# Kitty theme watcher - automatically reloads kitty when colors change
# This script watches for changes to the kitty colors.conf file

COLORS_FILE="$HOME/.config/kitty/colors.conf"
LAST_MODIFIED=""

# Function to reload all kitty instances
reload_kitty_instances() {
    echo "Colors changed, reloading kitty instances..."
    
    # Method 1: Use kitty remote control
    for socket in /tmp/kitty-*; do
        if [[ -S "$socket" ]]; then
            kitty @ --to "unix:$socket" reload-config 2>/dev/null || true
        fi
    done
    
    # Method 2: Use signal if no sockets found
    if ! ls /tmp/kitty-* 2>/dev/null; then
        pkill -USR1 kitty 2>/dev/null || true
    fi
    
    echo "Kitty instances reloaded"
}

# Main watch loop
while true; do
    if [[ -f "$COLORS_FILE" ]]; then
        CURRENT_MODIFIED=$(stat -c %Y "$COLORS_FILE" 2>/dev/null || echo "0")
        
        if [[ "$CURRENT_MODIFIED" != "$LAST_MODIFIED" ]]; then
            LAST_MODIFIED="$CURRENT_MODIFIED"
            reload_kitty_instances
        fi
    fi
    
    sleep 1
done
