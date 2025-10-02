#!/bin/bash

# Test script for lock screen setup
echo "🔒 Testing Lock Screen Setup"
echo "============================"

# Test 1: Check if hypridle and hyprlock are installed
echo "1️⃣ Checking installation..."
if command -v hypridle &> /dev/null && command -v hyprlock &> /dev/null; then
    echo "✅ hypridle and hyprlock are installed"
else
    echo "❌ hypridle or hyprlock not found"
    exit 1
fi

# Test 2: Check configuration files
echo ""
echo "2️⃣ Checking configuration files..."
if [[ -f "$HOME/.config/hypridle/hypridle.conf" ]]; then
    echo "✅ hypridle configuration exists"
else
    echo "❌ hypridle configuration missing"
fi

if [[ -f "$HOME/.config/hyprlock/hyprlock.conf" ]]; then
    echo "✅ hyprlock configuration exists"
else
    echo "❌ hyprlock configuration missing"
fi

# Test 3: Check helper scripts
echo ""
echo "3️⃣ Checking helper scripts..."
if [[ -x "$HOME/.config/hypr/scripts/songdetail.sh" ]]; then
    echo "✅ Song detail script exists and is executable"
else
    echo "❌ Song detail script missing or not executable"
fi

if [[ -x "$HOME/.config/hypr/scripts/weather.py" ]]; then
    echo "✅ Weather script exists and is executable"
else
    echo "❌ Weather script missing or not executable"
fi

# Test 4: Check user avatar
echo ""
echo "4️⃣ Checking user avatar..."
if [[ -f "$HOME/.face" ]]; then
    echo "✅ User avatar (.face) exists"
else
    echo "⚠️ User avatar missing - will use default"
    echo "   You can add your photo as ~/.face"
fi

# Test 5: Check if hypridle is running
echo ""
echo "5️⃣ Checking if hypridle is running..."
if pgrep -x hypridle > /dev/null; then
    echo "✅ hypridle is running"
else
    echo "⚠️ hypridle is not running"
    echo "   It will start automatically on next login"
fi

echo ""
echo "🧪 Test Commands:"
echo "   - Test lock screen: hyprlock"
echo "   - Start idle daemon: hypridle"
echo "   - Check idle status: pgrep hypridle"

echo ""
echo "⚙️ Configuration:"
echo "   - Lock after: 5 minutes of inactivity"
echo "   - Screen off after: 5.5 minutes"
echo "   - Suspend after: 30 minutes"
echo "   - Brightness dims after: 2.5 minutes"

echo ""
echo "🎨 Customization:"
echo "   - Edit ~/.config/hyprlock/hyprlock.conf for lock screen appearance"
echo "   - Edit ~/.config/hypridle/hypridle.conf for timing settings"
echo "   - Add ~/.face image for custom user avatar"
echo "   - Colors will update automatically with theme changes"

echo ""
echo "✨ Lock screen setup test completed!"
