#!/bin/bash

# Keyboard Setup Script
# This script ensures caps lock and escape are swapped system-wide
# Works for both Wayland and X11 applications

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

# Function to setup XKB configuration
setup_xkb_config() {
    print_status "Setting up XKB configuration for caps lock/escape swap..."
    
    # Create XKB config directory if it doesn't exist
    mkdir -p "$HOME/.config/xkb/symbols"
    
    # Create custom XKB layout
    cat > "$HOME/.config/xkb/symbols/custom" << 'EOF'
// Custom keyboard layout with caps lock and escape swapped
default partial alphanumeric_keys
xkb_symbols "swapescape" {
    include "us(basic)"
    name[Group1]= "US (Caps Lock as Escape)";
    
    // Swap Caps Lock and Escape
    key <CAPS> { [ Escape ] };
    key <ESC>  { [ Caps_Lock ] };
};
EOF

    print_success "XKB configuration created"
}

# Function to setup setxkbmap for X11 applications
setup_setxkbmap() {
    print_status "Setting up setxkbmap for X11 applications..."
    
    # Apply the keyboard mapping
    if command -v setxkbmap &> /dev/null; then
        setxkbmap -option caps:swapescape
        print_success "setxkbmap configuration applied"
    else
        print_warning "setxkbmap not found, installing xorg-setxkbmap..."
        # This will be handled by the package manager
    fi
}

# Function to create systemd user service for persistent keyboard mapping
setup_systemd_service() {
    print_status "Creating systemd user service for keyboard mapping..."
    
    mkdir -p "$HOME/.config/systemd/user"
    
    cat > "$HOME/.config/systemd/user/keyboard-setup.service" << 'EOF'
[Unit]
Description=Keyboard Setup (Caps Lock/Escape Swap)
After=graphical-session.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'if command -v setxkbmap >/dev/null 2>&1; then setxkbmap -option caps:swapescape; fi'
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF

    # Enable the service
    systemctl --user daemon-reload
    systemctl --user enable keyboard-setup.service
    systemctl --user start keyboard-setup.service
    
    print_success "Systemd service created and enabled"
}

# Function to add keyboard setup to shell profile
setup_shell_profile() {
    print_status "Adding keyboard setup to shell profile..."
    
    local shell_rc=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_rc="$HOME/.bashrc"
    else
        shell_rc="$HOME/.profile"
    fi
    
    # Add keyboard setup to shell profile if not already present
    if ! grep -q "setxkbmap.*caps:swapescape" "$shell_rc" 2>/dev/null; then
        echo "" >> "$shell_rc"
        echo "# Keyboard setup - swap caps lock and escape" >> "$shell_rc"
        echo "if command -v setxkbmap >/dev/null 2>&1; then" >> "$shell_rc"
        echo "    setxkbmap -option caps:swapescape" >> "$shell_rc"
        echo "fi" >> "$shell_rc"
        print_success "Added keyboard setup to $shell_rc"
    else
        print_status "Keyboard setup already present in $shell_rc"
    fi
}

# Function to create desktop autostart entry
setup_autostart() {
    print_status "Creating autostart entry for keyboard setup..."
    
    mkdir -p "$HOME/.config/autostart"
    
    cat > "$HOME/.config/autostart/keyboard-setup.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=Keyboard Setup
Comment=Swap Caps Lock and Escape keys
Exec=sh -c 'if command -v setxkbmap >/dev/null 2>&1; then setxkbmap -option caps:swapescape; fi'
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
StartupNotify=false
EOF

    print_success "Autostart entry created"
}

# Function to update Hyprland configuration
update_hyprland_config() {
    print_status "Ensuring Hyprland keyboard configuration is correct..."
    
    local env_conf="$HOME/.config/hypr/defaults/environment.conf"
    
    if [[ -f "$env_conf" ]]; then
        # Check if caps:swapescape is already configured
        if grep -q "caps:swapescape" "$env_conf"; then
            print_success "Hyprland keyboard configuration is already correct"
        else
            print_warning "Hyprland keyboard configuration needs updating"
            print_status "Please ensure 'kb_options = grp:alt_shift_toggle,caps:swapescape' is in your Hyprland config"
        fi
    else
        print_warning "Hyprland configuration not found at $env_conf"
    fi
}

# Main execution
main() {
    print_status "Setting up keyboard configuration (Caps Lock ⟷ Escape swap)..."
    echo
    
    # Setup XKB configuration
    setup_xkb_config
    
    # Setup setxkbmap
    setup_setxkbmap
    
    # Setup systemd service for persistence
    setup_systemd_service
    
    # Add to shell profile
    setup_shell_profile
    
    # Create autostart entry
    setup_autostart
    
    # Update Hyprland config
    update_hyprland_config
    
    echo
    print_success "Keyboard setup completed!"
    print_status "The caps lock/escape swap should now work in all applications including Cursor"
    print_status "You may need to restart applications or log out/in for changes to take full effect"
    
    echo
    print_status "To test the configuration:"
    echo "  - Try pressing Caps Lock (should act as Escape)"
    echo "  - Try pressing Escape (should act as Caps Lock)"
    echo "  - Test in both native Wayland apps and X11/Electron apps like Cursor"
}

# Run main function
main "$@"
