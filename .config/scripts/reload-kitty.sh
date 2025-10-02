#!/bin/bash

# Script to reload all kitty instances when theme changes
# This ensures all kitty terminals pick up the new color scheme

echo "Reloading all kitty instances..."

# Method 1: Use kitty's remote control to reload config
# This is the preferred method as it's more reliable
if command -v kitty &> /dev/null; then
    # Try to reload all kitty instances using remote control
    for socket in /tmp/kitty-*; do
        if [[ -S "$socket" ]]; then
            echo "Reloading kitty instance: $socket"
            kitty @ --to "unix:$socket" reload-config 2>/dev/null || true
        fi
    done
    
    # If no sockets found, try the alternative method
    if ! ls /tmp/kitty-* 2>/dev/null; then
        echo "No kitty sockets found, using signal method..."
        pkill -USR1 kitty 2>/dev/null || true
    fi
    
    echo "Kitty instances reloaded successfully"
else
    echo "Kitty not found in PATH"
    exit 1
fi
