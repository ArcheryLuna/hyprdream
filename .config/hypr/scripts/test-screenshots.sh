#!/bin/bash

# Test script for screenshot functionality
# This script tests all screenshot modes to ensure they work correctly

echo "🧪 Testing Screenshot System"
echo "=============================="

SCRIPT_PATH="$HOME/.config/hypr/scripts/screenshot.sh"

if [[ ! -x "$SCRIPT_PATH" ]]; then
    echo "❌ Screenshot script not found or not executable: $SCRIPT_PATH"
    exit 1
fi

echo "📁 Screenshots will be saved to: ~/screenshots"
echo ""

# Test 1: Help function
echo "1️⃣ Testing help function..."
if "$SCRIPT_PATH" --help > /dev/null 2>&1; then
    echo "✅ Help function works"
else
    echo "❌ Help function failed"
fi

# Test 2: Fullscreen (non-interactive)
echo ""
echo "2️⃣ Testing fullscreen screenshot..."
if "$SCRIPT_PATH" fullscreen --no-clipboard > /dev/null 2>&1; then
    echo "✅ Fullscreen screenshot works (saved to file only)"
else
    echo "❌ Fullscreen screenshot failed"
fi

# Test 2b: Test clipboard integration
echo ""
echo "2️⃣b Testing clipboard integration..."
if "$SCRIPT_PATH" fullscreen > /dev/null 2>&1; then
    if wl-paste | file - | grep -q "PNG image data"; then
        echo "✅ Screenshot copied to clipboard successfully"
    else
        echo "❌ Screenshot not copied to clipboard"
    fi
else
    echo "❌ Fullscreen screenshot with clipboard failed"
fi

# Test 3: Check if tools are available
echo ""
echo "3️⃣ Checking screenshot tools..."
if command -v grim &> /dev/null && command -v slurp &> /dev/null; then
    echo "✅ grim and slurp available (preferred)"
elif command -v hyprshot &> /dev/null; then
    echo "✅ hyprshot available (fallback)"
else
    echo "❌ No screenshot tools available"
fi

# Test 4: Check clipboard tool
echo ""
echo "4️⃣ Checking clipboard integration..."
if command -v wl-copy &> /dev/null; then
    echo "✅ wl-copy available for clipboard"
else
    echo "❌ wl-copy not available"
fi

# Test 5: Check notification system
echo ""
echo "5️⃣ Checking notification system..."
if command -v notify-send &> /dev/null; then
    echo "✅ notify-send available"
else
    echo "❌ notify-send not available"
fi

# Test 6: Check screenshot directory
echo ""
echo "6️⃣ Checking screenshot directory..."
if [[ -d "$HOME/screenshots" ]]; then
    echo "✅ Screenshot directory exists"
    echo "📊 Current screenshots: $(ls "$HOME/screenshots" | wc -l) files"
else
    echo "❌ Screenshot directory missing"
fi

echo ""
echo "🎯 Manual Tests (require user interaction):"
echo "   - Super + Print (fullscreen)"
echo "   - Super + Shift + S (region selection)"
echo "   - Super + Alt + S (window capture)"
echo "   - Super + Shift + M (monitor selection)"
echo "   - Super + Shift + Print (interactive mode)"

echo ""
echo "📋 To test keybindings:"
echo "   1. Press Super + Shift + S and select a region"
echo "   2. Press Super + Print for fullscreen"
echo "   3. Press Super + Shift + Print for interactive mode"

echo ""
echo "✨ Screenshot system test completed!"
