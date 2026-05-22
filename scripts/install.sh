#!/usr/bin/env bash

# Re-exec with bash when invoked via sh/dash/zsh (this script requires bash)
if [ -z "${BASH_VERSION:-}" ]; then
    exec bash "$0" "$@"
fi

# Dotfiles Installation Script - Improved for better reliability
# This script installs all essential packages for the rice configuration

set -e  # Exit on any error
set -o pipefail

# Test mode - set to true to simulate without making changes
TEST_MODE=${TEST_MODE:-false}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_test() { echo -e "${YELLOW}[TEST MODE]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check for required commands early
require_cmd() {
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            print_error "Required command not found: $cmd"
            exit 1
        fi
    done
}

# Don't run as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root."
    exit 1
fi

# Get the directory where the script is located, then dotfiles dir
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
PKGLIST_FILE="$DOTFILES_DIR/pkglist.txt"

# Core check: pkglist must exist
if [[ ! -f "$PKGLIST_FILE" ]]; then
    print_error "Package list not found at $PKGLIST_FILE"
    exit 1
fi

# Set TEST_MODE warning early
if [[ "$TEST_MODE" == "true" ]]; then
    print_test "Running in TEST MODE - no actual changes will be made"
    print_test "To run for real, use: TEST_MODE=false ./scripts/install.sh"
fi

print_status "Starting dotfiles installation..."
print_status "Dotfiles directory: $DOTFILES_DIR"

########################################
# Helper to run or echo depending on TEST_MODE
run() {
    if [[ "$TEST_MODE" == "true" ]]; then
        print_test "Would run: $*"
    else
        eval "$@"
    fi
}
sudorun() {
    if [[ "$TEST_MODE" == "true" ]]; then
        print_test "Would run (sudo): $*"
    else
        sudo bash -c "$*"
    fi
}

# Stow packages mirror destination paths (xdg/.config -> ~/.config, etc.)
STOW_PACKAGES=(xdg themes ssh home)
STOW_NEVER=(previews sddm-theme scripts Wallpapers)

cleanup_bad_stow_links() {
    print_status "Cleaning incorrectly stowed symlinks from ${HOME}..."

    for pkg in "${STOW_NEVER[@]}"; do
        if [[ -d "${DOTFILES_DIR}/${pkg}" ]]; then
            stow -D -t "${HOME}" "${pkg}" 2>/dev/null || true
        fi
    done

    if [[ -d "${DOTFILES_DIR}/xdg/.config" ]]; then
        for cfg_dir in "${DOTFILES_DIR}/xdg/.config"/*/; do
            local name
            name=$(basename "${cfg_dir}")
            if [[ -L "${HOME}/${name}" ]]; then
                rm "${HOME}/${name}"
            fi
        done
    fi

    local junk=(
        Backgrounds Components Configs Icons Main.qml metadata.desktop Preview repo_assets
        Dracula-City.png Nord-Green.png Tokyo-Night.png sddm-preview.png
    )
    for item in "${junk[@]}"; do
        [[ -L "${HOME}/${item}" ]] && rm "${HOME}/${item}"
    done
}

resolve_stow_conflicts() {
    local hypr_conf="${HOME}/.config/hypr/hyprland.conf"
    local ssh_conf="${HOME}/.ssh/config"

    if [[ -f "${hypr_conf}" && ! -L "${hypr_conf}" ]]; then
        local backup_dir="${HOME}/.config/hypr.autogen.bak"
        print_warning "Replacing auto-generated ~/.config/hypr (backup: ${backup_dir})"
        rm -rf "${backup_dir}"
        mv "${HOME}/.config/hypr" "${backup_dir}"
    fi

    if [[ -f "${ssh_conf}" && ! -L "${ssh_conf}" ]]; then
        local ssh_backup="${HOME}/.ssh/config.autogen.bak"
        print_warning "Backing up existing ~/.ssh/config to ${ssh_backup}"
        mv "${ssh_conf}" "${ssh_backup}"
    fi
}

stow_dotfiles() {
    local pkg
    local legacy_pkg

    cd "${DOTFILES_DIR}"

    for legacy_pkg in .config .themes .ssh "${STOW_PACKAGES[@]}" "${STOW_NEVER[@]}"; do
        [[ -e "${legacy_pkg}" ]] || continue
        stow -D -t "${HOME}" "${legacy_pkg}" 2>/dev/null || true
    done

    resolve_stow_conflicts

    for pkg in "${STOW_PACKAGES[@]}"; do
        if [[ ! -e "${pkg}" ]]; then
            print_warning "Stow package not found, skipping: ${pkg}"
            continue
        fi
        print_status "Stowing ${pkg}..."
        stow -t "${HOME}" "${pkg}"
    done
}

########################################
# Install yay if not present
install_yay() {
    print_status "Installing yay AUR helper..."

    if ! command -v git &>/dev/null; then
        print_status "Installing git and base-devel first..."
        run "sudo pacman -S --noconfirm git base-devel"
    fi

    cd /tmp
    rm -rf yay
    run "git clone https://aur.archlinux.org/yay.git"
    cd yay
    run "makepkg -si --noconfirm"
    cd "$DOTFILES_DIR"
    print_success "yay installed successfully!"
}

########################################
# Install chaotic-aur if not present
install_chaotic_aur() {
    print_status "Checking for Chaotic-AUR repository..."

    local CHAOTIC_SIG_KEY="3056513887B78AEB"
    local CHAOTIC_KEYRING_URL="https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst"
    local CHAOTIC_MIRRORLIST_URL="https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst"
    local KEY_EXISTS
    KEY_EXISTS=$(pacman-key --list-keys "$CHAOTIC_SIG_KEY" 2>/dev/null | grep -c "$CHAOTIC_SIG_KEY" || true)

    local CHAOTIC_REPO_PRESENT=0
    if grep -q "^\[chaotic-aur\]" /etc/pacman.conf; then
        CHAOTIC_REPO_PRESENT=1
    fi

    if [[ "$TEST_MODE" == "true" ]]; then
        if [[ "$CHAOTIC_REPO_PRESENT" -eq 0 ]]; then
            print_test "Would install the Chaotic-AUR repository."
            print_test "Would run: pacman-key --recv-key $CHAOTIC_SIG_KEY"
            print_test "Would run: pacman -U $CHAOTIC_KEYRING_URL $CHAOTIC_MIRRORLIST_URL"
            print_test "Would append [chaotic-aur] to /etc/pacman.conf"
        else
            print_test "Chaotic-AUR already configured."
        fi
        return 0
    fi

    if [[ "$CHAOTIC_REPO_PRESENT" -eq 1 ]]; then
        print_success "Chaotic-AUR repository already present."
        return 0
    fi

    print_status "Installing Chaotic-AUR repository..."

    if [[ "$KEY_EXISTS" -eq 0 ]]; then
        sudo pacman-key --recv-key "$CHAOTIC_SIG_KEY" --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key "$CHAOTIC_SIG_KEY"
    fi

    # Bootstrap keyring + mirrorlist from CDN (not in official repos yet)
    sudo pacman -U --noconfirm --needed \
        "$CHAOTIC_KEYRING_URL" \
        "$CHAOTIC_MIRRORLIST_URL"

    if ! grep -q "^\[chaotic-aur\]" /etc/pacman.conf; then
        print_status "Adding [chaotic-aur] to /etc/pacman.conf..."
        sudo tee -a /etc/pacman.conf > /dev/null <<EOF

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
    fi

    sudo pacman -Syyu --noconfirm
    print_success "Chaotic-AUR repository added!"
}

########################################
# Step 1: Ensure yay is installed
print_status "Step 1: Checking for yay AUR helper..."
if ! command -v yay &>/dev/null; then
    print_warning "yay AUR helper not found"
    if [[ "$TEST_MODE" == "true" ]]; then
        print_test "Would prompt to install yay"
        print_test "Would run yay installation"
        print_test "Would install Chaotic-AUR after yay"
        # Do nothing more in test mode
    else
        printf 'Do you want to install yay now? [y/N] '
        read -r -n 1 REPLY
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_yay
            install_chaotic_aur
        else
            print_error "yay is required for this installation"
            print_status "Please install yay manually: https://github.com/Jguer/yay"
            exit 1
        fi
    fi
else
    print_success "yay is already installed"
    # Even if yay is installed, make sure Chaotic-AUR
    install_chaotic_aur
fi

########################################
# Step 2: Update system
echo
print_status "Step 2: Updating system packages..."
if [[ "$TEST_MODE" == "true" ]]; then
    print_test "Would prompt for system update"
    print_test "Would run: sudo pacman -Syu --noconfirm"
else
    read -p "Do you want to update the system now? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        sudo pacman -Syu --noconfirm
        print_success "System updated successfully!"
    else
        print_warning "Skipping system update"
    fi
fi

########################################
# Step 3: Install packages from pkglist.txt
echo
print_status "Step 3: Installing packages from pkglist.txt..."
PKGCOUNT="$(grep -v '^#' "$PKGLIST_FILE" | grep -v '^$' | wc -l)"
print_status "This will install $PKGCOUNT packages"
if [[ "$TEST_MODE" == "true" ]]; then
    print_test "Would prompt for package installation"
    print_test "Would run yay on pkglist.txt"
else
    read -p "Do you want to proceed with package installation? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
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
fi

########################################
# Step 4: Enable essential services
echo
print_status "Step 4: Enabling essential services..."
SERVICES=(NetworkManager bluetooth sddm)
if [[ "$TEST_MODE" == "true" ]]; then
    print_test "Would prompt for enabling: ${SERVICES[*]}"
    for svc in "${SERVICES[@]}"; do
        print_test "Would run: sudo systemctl enable $svc"
        print_test "Would run: sudo systemctl start $svc"
    done
else
    read -p "Do you want to enable system services (NetworkManager, Bluetooth, SDDM)? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        for svc in "${SERVICES[@]}"; do
            sudo systemctl enable "$svc"
        done
        print_status "Starting services..."
        sudo systemctl start NetworkManager
        sudo systemctl start bluetooth
        print_success "Services enabled and started!"
    else
        print_warning "Skipping service configuration"
    fi
fi

########################################
# Step 5: Setup dotfiles with stow
echo
print_status "Step 5: Setting up dotfiles with stow..."
require_cmd stow
if [[ "$TEST_MODE" == "true" ]]; then
    print_test "Would clean bad stow symlinks from ~"
    print_test "Would stow packages: ${STOW_PACKAGES[*]}"
else
    read -p "Do you want to set up dotfiles with stow? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        cleanup_bad_stow_links
        stow_dotfiles
        print_success "Dotfiles linked: ~/.config, ~/.themes, ~/.ssh, ~/.zshrc"
    else
        print_warning "Skipping dotfiles setup"
    fi
fi

########################################
# Step 6: Set up fonts and themes
echo
print_status "Step 6: Setting up fonts and themes..."
if [[ "$TEST_MODE" == "true" ]]; then
    print_test "Would prompt for fonts/themes"
    print_test "Would run: fc-cache -f -v"
    print_test "Would run theme scripts if present"
else
    read -p "Do you want to set up fonts and themes? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        print_status "Rebuilding font cache..."
        fc-cache -f -v

        print_status "Setting up themes..."
        if [[ -f "$HOME/.config/scripts/ensure-dark-themes.sh" ]]; then
            chmod +x "$HOME/.config/scripts/ensure-dark-themes.sh"
            "$HOME/.config/scripts/ensure-dark-themes.sh"
        fi

        print_status "Initializing Hyprland configuration..."
        if [[ -f "$HOME/.config/hypr/scripts/init-theme.sh" ]]; then
            chmod +x "$HOME/.config/hypr/scripts/init-theme.sh"
            "$HOME/.config/hypr/scripts/init-theme.sh"
        fi

        print_success "Fonts and themes setup completed!"
    else
        print_warning "Skipping fonts and themes setup"
    fi
fi

########################################
# Step 7: Set up wallpapers and scripts
echo
print_status "Step 7: Setting up wallpapers and making scripts executable..."
if [[ "$TEST_MODE" == "true" ]]; then
    print_test "Would prompt for wallpaper/script setup"
    print_test "Would copy wallpapers, chmod +x scripts, mkdir -p fzf config"
else
    read -p "Do you want to set up wallpapers and make scripts executable? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        print_status "Setting up wallpapers..."
        mkdir -p "$HOME/Wallpapers"
        if [[ -d "$DOTFILES_DIR/Wallpapers" ]]; then
            cp -r "$DOTFILES_DIR/Wallpapers/"* "$HOME/Wallpapers/" 2>/dev/null || true
        fi

        print_status "Making scripts executable..."
        find "$HOME/.config" -name "*.sh" -type f -exec chmod +x {} \;

        print_status "Setting up FZF configuration..."
        mkdir -p "$HOME/.config/fzf"

        print_success "Wallpapers and scripts setup completed!"
    else
        print_warning "Skipping wallpapers and scripts setup"
    fi
fi

########################################
# Step 8: Setup SDDM theme
echo
print_status "Step 8: Setting up SDDM theme..."
if [[ "$TEST_MODE" == "true" ]]; then
    print_test "Would prompt for SDDM theme"
    print_test "Would check/copy/set theme if sddm-theme dir exists"
else
    read -p "Do you want to set up the SDDM theme? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        if [[ -d "$DOTFILES_DIR/sddm-theme" ]]; then
            print_status "Installing SDDM theme..."

            sudo mkdir -p /usr/share/sddm/themes/
            sudo rm -rf /usr/share/sddm/themes/vitreous
            sudo cp -r "$DOTFILES_DIR/sddm-theme" /usr/share/sddm/themes/vitreous
            sudo chown -R root:root /usr/share/sddm/themes/vitreous
            sudo chmod -R 755 /usr/share/sddm/themes/vitreous

            sudo mkdir -p /etc/sddm.conf.d/
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
fi

########################################
# Step 9: Setup display configuration
echo
print_status "Step 9: Setting up display configuration..."
if [[ "$TEST_MODE" == "true" ]]; then
    print_test "Would prompt for display setup"
    print_test "Would run and chmod +x ~/.config/hypr/scripts/setup-displays.sh if it exists"
else
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
fi

########################################
# Step 10: Setup keyboard configuration
echo
print_status "Step 10: Setting up keyboard configuration (Caps Lock ⟷ Escape swap)..."
if [[ "$TEST_MODE" == "true" ]]; then
    print_test "Would prompt for keyboard setup"
    print_test "Would run and chmod +x ~/.config/scripts/setup-keyboard.sh if it exists"
else
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
fi

########################################
# Step 11: Setup Zsh as default shell
echo
print_status "Step 11: Setting up Zsh as default shell..."
require_cmd git
if [[ "$TEST_MODE" == "true" ]]; then
    print_test "Would prompt to set default shell to zsh and set up plugins/starship config"
else
    read -p "Do you want to change your default shell to Zsh? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        if command -v zsh &> /dev/null; then
            current_shell=$(basename "$SHELL")
            if [[ "$current_shell" != "zsh" ]]; then
                print_status "Changing default shell to zsh..."
                if chsh -s "$(which zsh)"; then
                    print_success "Default shell changed to zsh"
                    print_status "You'll need to log out and back in for the change to take effect"
                else
                    print_warning "Failed to change shell. You may need to run: chsh -s $(which zsh)"
                fi
            else
                print_success "Zsh is already your default shell"
            fi

            print_status "Setting up zsh configuration..."
            mkdir -p "$HOME/.local/share/zsh/plugins"
            mkdir -p "$HOME/.cache/zsh"
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

            # Initialize starship config if not present
            if command -v starship &>/dev/null && [[ ! -f "$HOME/.config/starship.toml" ]]; then
                print_status "Initializing Starship prompt configuration..."
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
fi

########################################
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
