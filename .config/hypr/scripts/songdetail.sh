#!/bin/bash

# Get current playing song info for lock screen
# Works with various media players

# Try playerctl first (most common)
if command -v playerctl &> /dev/null; then
    # Get the currently playing track
    artist=$(playerctl metadata artist 2>/dev/null)
    title=$(playerctl metadata title 2>/dev/null)
    
    if [[ -n "$artist" && -n "$title" ]]; then
        echo "♪ $artist - $title"
        exit 0
    fi
fi

# Try getting info from MPRIS
if command -v dbus-send &> /dev/null; then
    # Check if any media player is running
    players=$(dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames 2>/dev/null | grep "org.mpris.MediaPlayer2" | head -1)
    
    if [[ -n "$players" ]]; then
        echo "♪ Music Playing"
        exit 0
    fi
fi

# Fallback - no music playing
echo ""
