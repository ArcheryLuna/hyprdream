#!/bin/bash

# Test script for install.sh
# This script validates the install script without making changes

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    print_status "Testing: $test_name"
    
    if eval "$test_command" &>/dev/null; then
        print_success "$test_name"
        ((TESTS_PASSED++))
    else
        print_error "$test_name"
        ((TESTS_FAILED++))
    fi
}

echo "🧪 Testing dotfiles installation script..."
echo

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
INSTALL_SCRIPT="$SCRIPT_DIR/install.sh"

print_status "Dotfiles directory: $DOTFILES_DIR"
print_status "Install script: $INSTALL_SCRIPT"
echo

# Test 1: Check if install script exists and is executable
run_test "Install script exists" "[[ -f '$INSTALL_SCRIPT' ]]"
run_test "Install script is executable" "[[ -x '$INSTALL_SCRIPT' ]]"

# Test 2: Check if required files exist
run_test "Package list exists" "[[ -f '$DOTFILES_DIR/pkglist.txt' ]]"
run_test "Stow ignore file exists" "[[ -f '$DOTFILES_DIR/.stow-local-ignore' ]]"
run_test "Gitignore file exists" "[[ -f '$DOTFILES_DIR/.gitignore' ]]"

# Test 3: Check if configuration directories exist
run_test ".config directory exists" "[[ -d '$DOTFILES_DIR/.config' ]]"
run_test "Hyprland config exists" "[[ -d '$DOTFILES_DIR/.config/hypr' ]]"
run_test "Waybar config exists" "[[ -d '$DOTFILES_DIR/.config/waybar' ]]"
run_test "Swaync config exists" "[[ -d '$DOTFILES_DIR/.config/swaync' ]]"

# Test 4: Check if essential scripts exist
run_test "Display setup script exists" "[[ -f '$DOTFILES_DIR/.config/hypr/scripts/setup-displays.sh' ]]"
run_test "Keyboard setup script exists" "[[ -f '$DOTFILES_DIR/.config/scripts/setup-keyboard.sh' ]]"
run_test "Theme switcher exists" "[[ -f '$DOTFILES_DIR/.config/waybar/scripts/theme-switcher-v2.sh' ]]"

# Test 5: Check if SDDM theme exists
run_test "SDDM theme directory exists" "[[ -d '$DOTFILES_DIR/sddm-theme' ]]"

# Test 6: Validate package list
if [[ -f "$DOTFILES_DIR/pkglist.txt" ]]; then
    PACKAGE_COUNT=$(grep -v '^#' "$DOTFILES_DIR/pkglist.txt" | grep -v '^$' | wc -l)
    run_test "Package list has packages (count: $PACKAGE_COUNT)" "[[ $PACKAGE_COUNT -gt 0 ]]"
    run_test "Package list has reasonable count" "[[ $PACKAGE_COUNT -gt 50 && $PACKAGE_COUNT -lt 200 ]]"
fi

# Test 7: Check script syntax
run_test "Install script syntax is valid" "bash -n '$INSTALL_SCRIPT'"

# Test 8: Check for required commands in script
run_test "Script checks for yay" "grep -q 'yay' '$INSTALL_SCRIPT'"
run_test "Script uses stow" "grep -q 'stow' '$INSTALL_SCRIPT'"
run_test "Script has step organization" "grep -q 'Step [0-9]' '$INSTALL_SCRIPT'"

# Test 9: Validate essential packages are in list
if [[ -f "$DOTFILES_DIR/pkglist.txt" ]]; then
    run_test "Hyprland package listed" "grep -q '^hyprland' '$DOTFILES_DIR/pkglist.txt'"
    run_test "Kitty package listed" "grep -q '^kitty' '$DOTFILES_DIR/pkglist.txt'"
    run_test "Waybar package listed" "grep -q '^waybar' '$DOTFILES_DIR/pkglist.txt'"
    run_test "Zsh package listed" "grep -q '^zsh' '$DOTFILES_DIR/pkglist.txt'"
    run_test "Starship package listed" "grep -q '^starship' '$DOTFILES_DIR/pkglist.txt'"
    run_test "Font packages listed" "grep -q 'nerd-font\|jetbrains' '$DOTFILES_DIR/pkglist.txt'"
fi

# Test 10: Check zsh configuration
run_test "Zshrc file exists" "[[ -f '$DOTFILES_DIR/.zshrc' ]]"

echo
echo "📊 Test Results:"
echo "  ✅ Passed: $TESTS_PASSED"
echo "  ❌ Failed: $TESTS_FAILED"
echo "  📋 Total:  $((TESTS_PASSED + TESTS_FAILED))"

if [[ $TESTS_FAILED -eq 0 ]]; then
    print_success "All tests passed! The install script should work correctly."
    echo
    echo "🚀 Next steps to test:"
    echo "  1. Syntax check: bash -n scripts/install.sh"
    echo "  2. Dry run: TEST_MODE=true ./scripts/install.sh"
    echo "  3. VM test: Test in a virtual machine"
    echo "  4. Container test: Test in a Docker container"
    echo "  5. Fresh system: Test on a clean Arch installation"
else
    print_error "Some tests failed. Please fix the issues before running the install script."
    exit 1
fi
