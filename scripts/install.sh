#!/bin/bash

# Dotfiles Installation Script
# This script installs all essential packages for the rice configuration

set -e  # Exit on any error

# Test mode - set to true to simulate without making changes
TEST_MODE=${TEST_MODE:-false}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_test() {
    echo -e "${YELLOW}[TEST MODE]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

# Function to install yay if not present
install_yay() {
    print_status "Installing yay AUR helper..."
    
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        print_status "Installing git first..."
        sudo pacman -S --noconfirm git base-devel
    fi
    
    # Clone and install yay
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd "$DOTFILES_DIR"
    
    print_success "yay installed successfully!"
}

# Step 1: Check if yay is installed
print_status "Step 1: Checking for yay AUR helper..."
if ! command -v yay &> /dev/null; then
    print_warning "yay AUR helper not found"
    read -p "Do you want to install yay now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_yay
    else
        print_error "yay is required for this installation"
        print_status "Please install yay manually: https://github.com/Jguer/yay"
        exit 1
    fi
else
    print_success "yay is already installed"
fi

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
PKGLIST_FILE="$DOTFILES_DIR/pkglist.txt"

# Check if package list exists
if [[ ! -f "$PKGLIST_FILE" ]]; then
    print_error "Package list not found at $PKGLIST_FILE"
    exit 1
fi

echo
if [[ "$TEST_MODE" == "true" ]]; then
    print_test "Running in TEST MODE - no actual changes will be made"
    print_test "To run for real, use: TEST_MODE=false ./scripts/install.sh"
fi

print_status "Starting dotfiles installation..."
print_status "Dotfiles directory: $DOTFILES_DIR"

# Step 2: Update system
echo
print_status "Step 2: Updating system packages..."
read -p "Do you want to update the system now? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    sudo pacman -Syu --noconfirm
    print_success "System updated successfully!"
else
    print_warning "Skipping system update"
fi

# Step 3: Install packages
echo
print_status "Step 3: Installing packages from pkglist.txt..."
print_status "This will install $(grep -v '^#' "$PKGLIST_FILE" | grep -v '^$' | wc -l) packages"
read -p "Do you want to proceed with package installation? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    # Filter out comments and empty lines, then install
    grep -v '^#' "$PKGLIST_FILE" | grep -v '^$' | while read -r package; do
        if [[ -n "$package" ]]; then
            print_status "Installing: $package"
            yay -S --noconfirm "$package" || print_warning "Failed to install $package"
        fi
    done
    print_success "Package installation completed!"
else
    print_warning "Skipping package installation"
fi

# Step 4: Enable essential services
echo
print_status "Step 4: Enabling essential services..."
read -p "Do you want to enable system services (NetworkManager, Bluetooth, SDDM)? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    sudo systemctl enable NetworkManager
    sudo systemctl enable bluetooth
    sudo systemctl enable sddm
    
    # Start services
    print_status "Starting services..."
    sudo systemctl start NetworkManager
    sudo systemctl start bluetooth
    print_success "Services enabled and started!"
else
    print_warning "Skipping service configuration"
fi

# Step 5: Setup dotfiles with stow
echo
print_status "Step 5: Setting up dotfiles with stow..."
read -p "Do you want to set up dotfiles with stow? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    cd "$DOTFILES_DIR"
    
    # Stow all configuration directories
    for dir in */; do
        if [[ -d "$dir" && "$dir" != "scripts/" && "$dir" != "Wallpapers/" ]]; then
            print_status "Stowing $dir..."
            stow "$dir" || print_warning "Failed to stow $dir"
        fi
    done
    
    # Special handling for .config directories
    if [[ -d ".config" ]]; then
        print_status "Stowing .config..."
        stow .config || print_warning "Failed to stow .config"
    fi
    
    if [[ -d ".local" ]]; then
        print_status "Stowing .local..."
        stow .local || print_warning "Failed to stow .local"
    fi
    
    print_success "Dotfiles setup completed!"
else
    print_warning "Skipping dotfiles setup"
fi

# Step 6: Set up fonts and themes
echo
print_status "Step 6: Setting up fonts and themes..."
read -p "Do you want to set up fonts and themes? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    # Set up fonts
    print_status "Rebuilding font cache..."
    fc-cache -f -v
    
    # Set up themes
    print_status "Setting up themes..."
    if [[ -f "$HOME/.config/scripts/ensure-dark-themes.sh" ]]; then
        chmod +x "$HOME/.config/scripts/ensure-dark-themes.sh"
        "$HOME/.config/scripts/ensure-dark-themes.sh"
    fi
    
    # Initialize Hyprland configuration
    print_status "Initializing Hyprland configuration..."
    if [[ -f "$HOME/.config/hypr/scripts/init-theme.sh" ]]; then
        chmod +x "$HOME/.config/hypr/scripts/init-theme.sh"
        "$HOME/.config/hypr/scripts/init-theme.sh"
    fi
    
    print_success "Fonts and themes setup completed!"
else
    print_warning "Skipping fonts and themes setup"
fi

# Step 7: Set up wallpapers and scripts
echo
print_status "Step 7: Setting up wallpapers and making scripts executable..."
read -p "Do you want to set up wallpapers and make scripts executable? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    # Set up wallpapers directory
    print_status "Setting up wallpapers..."
    mkdir -p "$HOME/Wallpapers"
    if [[ -d "$DOTFILES_DIR/Wallpapers" ]]; then
        cp -r "$DOTFILES_DIR/Wallpapers/"* "$HOME/Wallpapers/" 2>/dev/null || true
    fi
    
        # Make scripts executable
        print_status "Making scripts executable..."
        find "$HOME/.config" -name "*.sh" -type f -exec chmod +x {} \;
        
        # Create FZF config directory
        print_status "Setting up FZF configuration..."
        mkdir -p "$HOME/.config/fzf"
    
    print_success "Wallpapers and scripts setup completed!"
else
    print_warning "Skipping wallpapers and scripts setup"
fi

# Step 8: Setup SDDM theme
echo
print_status "Step 8: Setting up SDDM theme..."
read -p "Do you want to set up the SDDM theme? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    if [[ -d "$DOTFILES_DIR/sddm-theme" ]]; then
        print_status "Installing SDDM theme..."
        
        # Create SDDM themes directory if it doesn't exist
        sudo mkdir -p /usr/share/sddm/themes/
        
        # Copy the theme
        sudo cp -r "$DOTFILES_DIR/sddm-theme" /usr/share/sddm/themes/vitreous
        
        # Set proper permissions
        sudo chown -R root:root /usr/share/sddm/themes/vitreous
        sudo chmod -R 755 /usr/share/sddm/themes/vitreous
        
        # Create SDDM config directory if it doesn't exist
        sudo mkdir -p /etc/sddm.conf.d/
        
        # Create SDDM configuration to use the theme
        print_status "Configuring SDDM to use the theme..."
        sudo tee /etc/sddm.conf.d/theme.conf > /dev/null <<EOF
[Theme]
Current=vitreous
CursorTheme=mcmojave-cursors
CursorSize=24

[General]
Numlock=on
EOF
        
        print_success "SDDM theme installed and configured!"
        print_status "The theme will be active after reboot"
    else
        print_warning "SDDM theme directory not found at $DOTFILES_DIR/sddm-theme"
    fi
else
    print_warning "Skipping SDDM theme setup"
fi

# Step 9: Setup display configuration
echo
print_status "Step 9: Setting up display configuration..."
read -p "Do you want to auto-configure displays for optimal resolution/refresh rate? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    if [[ -f "$HOME/.config/hypr/scripts/setup-displays.sh" ]]; then
        print_status "Running display auto-configuration..."
        chmod +x "$HOME/.config/hypr/scripts/setup-displays.sh"
        "$HOME/.config/hypr/scripts/setup-displays.sh"
        print_success "Display configuration completed!"
    else
        print_warning "Display setup script not found"
        print_status "You can manually run it later with: ~/.config/hypr/scripts/setup-displays.sh"
    fi
else
    print_warning "Skipping display configuration"
    print_status "Using default configuration (preferred resolution for all monitors)"
fi

# Step 10: Setup keyboard configuration
echo
print_status "Step 10: Setting up keyboard configuration (Caps Lock ⟷ Escape swap)..."
read -p "Do you want to set up caps lock/escape swap for all applications? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    if [[ -f "$HOME/.config/scripts/setup-keyboard.sh" ]]; then
        print_status "Running keyboard configuration setup..."
        chmod +x "$HOME/.config/scripts/setup-keyboard.sh"
        "$HOME/.config/scripts/setup-keyboard.sh"
        print_success "Keyboard configuration completed!"
    else
        print_warning "Keyboard setup script not found"
        print_status "You can manually run it later with: ~/.config/scripts/setup-keyboard.sh"
    fi
else
    print_warning "Skipping keyboard configuration"
fi

# Step 11: Setup Zsh as default shell
echo
print_status "Step 11: Setting up Zsh as default shell..."
read -p "Do you want to change your default shell to Zsh? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    # Check if zsh is installed
    if command -v zsh &> /dev/null; then
        # Get current shell
        current_shell=$(basename "$SHELL")
        
        if [[ "$current_shell" != "zsh" ]]; then
            print_status "Changing default shell to zsh..."
            
            # Change shell for current user
            if chsh -s "$(which zsh)"; then
                print_success "Default shell changed to zsh"
                print_status "You'll need to log out and back in for the change to take effect"
            else
                print_warning "Failed to change shell. You may need to run: chsh -s \$(which zsh)"
            fi
        else
            print_success "Zsh is already your default shell"
        fi
        
        # Setup zsh configuration
        print_status "Setting up zsh configuration..."
        
        # Create zsh directories
        mkdir -p "$HOME/.local/share/zsh/plugins"
        mkdir -p "$HOME/.cache/zsh"
        
        # Install zsh plugins
        print_status "Installing zsh plugins..."
        
        # Syntax highlighting
        if [[ ! -d "$HOME/.local/share/zsh/plugins/zsh-syntax-highlighting" ]]; then
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
                "$HOME/.local/share/zsh/plugins/zsh-syntax-highlighting" 2>/dev/null || \
                print_warning "Failed to install zsh-syntax-highlighting"
        fi
        
        # Autosuggestions
        if [[ ! -d "$HOME/.local/share/zsh/plugins/zsh-autosuggestions" ]]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions.git \
                "$HOME/.local/share/zsh/plugins/zsh-autosuggestions" 2>/dev/null || \
                print_warning "Failed to install zsh-autosuggestions"
        fi
        
        # History substring search
        if [[ ! -d "$HOME/.local/share/zsh/plugins/zsh-history-substring-search" ]]; then
            git clone https://github.com/zsh-users/zsh-history-substring-search.git \
                "$HOME/.local/share/zsh/plugins/zsh-history-substring-search" 2>/dev/null || \
                print_warning "Failed to install zsh-history-substring-search"
        fi
        
        print_success "Zsh plugins installed!"
        
        # Initialize starship config if it doesn't exist
        if command -v starship &> /dev/null && [[ ! -f "$HOME/.config/starship.toml" ]]; then
            print_status "Initializing Starship prompt configuration..."
            # The starship config will be created by matugen from the template
            if [[ -f "$HOME/.config/matugen/templates/starship-colors.toml" ]]; then
                cp "$HOME/.config/matugen/templates/starship-colors.toml" "$HOME/.config/starship.toml"
                print_success "Starship configuration initialized"
            fi
        fi
        
        print_success "Zsh setup completed!"
        
    else
        print_error "Zsh is not installed. Please install it first."
    fi
else
    print_warning "Skipping zsh setup"
fi

print_success "Dotfiles installation completed successfully!"
print_status "Please reboot your system to ensure all changes take effect."
print_status "After reboot, you can start Hyprland from your display manager or TTY."

echo
print_status "Post-installation notes:"
echo "  - Configure your display manager to use Hyprland"
echo "  - Log out and back in if you changed your shell to zsh"
echo "  - Run 'matugen image /path/to/wallpaper' to generate colors from a wallpaper"
echo "  - Use Super+T to switch themes"
echo "  - Use Super+Space to open the application launcher (walker)"
echo "  - Check ~/.config/hypr/hyprland.conf for keybindings"
echo "  - Your zsh is configured with syntax highlighting, autosuggestions, and starship prompt"
echo "  - Use 'z' instead of 'cd' for smart directory navigation (zoxide)"
echo "  - FZF colors will automatically match your theme when you run matugen"
echo "  - Use Ctrl+R for history search, Ctrl+T for file search, Alt+C for directory search"
