#!/usr/bin/env bash

# Fix dotfiles stow layout: configs belong in ~/.config, not ~

set -euo pipefail

if [ -z "${BASH_VERSION:-}" ]; then
    exec bash "$0" "$@"
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
STOW_TARGET="${HOME}"

STOW_PACKAGES=(xdg themes ssh home)
STOW_NEVER=(previews sddm-theme scripts Wallpapers)

cleanup_bad_stow_links() {
    print_status "Removing incorrectly stowed symlinks from ${STOW_TARGET}..."

    for pkg in "${STOW_NEVER[@]}"; do
        if [[ -d "${DOTFILES_DIR}/${pkg}" ]]; then
            stow -D -t "${STOW_TARGET}" "${pkg}" 2>/dev/null || true
        fi
    done

    if [[ -d "${DOTFILES_DIR}/xdg/.config" ]]; then
        for cfg_dir in "${DOTFILES_DIR}/xdg/.config"/*/; do
            local name
            name=$(basename "${cfg_dir}")
            if [[ -L "${STOW_TARGET}/${name}" ]]; then
                rm "${STOW_TARGET}/${name}"
                print_status "Removed ~/${name}"
            fi
        done
    fi

    local junk=(
        Backgrounds Components Configs Icons Main.qml metadata.desktop Preview repo_assets
        Dracula-City.png Nord-Green.png Tokyo-Night.png sddm-preview.png
    )
    for item in "${junk[@]}"; do
        if [[ -L "${STOW_TARGET}/${item}" ]]; then
            rm "${STOW_TARGET}/${item}"
            print_status "Removed ~/${item}"
        fi
    done
}

resolve_stow_conflicts() {
    local hypr_conf="${STOW_TARGET}/.config/hypr/hyprland.conf"
    local ssh_conf="${STOW_TARGET}/.ssh/config"

    if [[ -f "${hypr_conf}" && ! -L "${hypr_conf}" ]]; then
        local backup_dir="${STOW_TARGET}/.config/hypr.autogen.bak"
        print_warning "Replacing auto-generated ~/.config/hypr (backup: ${backup_dir})"
        rm -rf "${backup_dir}"
        mv "${STOW_TARGET}/.config/hypr" "${backup_dir}"
    fi

    if [[ -f "${ssh_conf}" && ! -L "${ssh_conf}" ]]; then
        local ssh_backup="${STOW_TARGET}/.ssh/config.autogen.bak"
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
        stow -D -t "${STOW_TARGET}" "${legacy_pkg}" 2>/dev/null || true
    done

    resolve_stow_conflicts

    for pkg in "${STOW_PACKAGES[@]}"; do
        if [[ ! -e "${pkg}" ]]; then
            print_warning "Skipping missing package: ${pkg}"
            continue
        fi
        print_status "Stowing ${pkg} -> ${STOW_TARGET}"
        stow -t "${STOW_TARGET}" "${pkg}"
    done
}

require_cmd() {
    command -v "$1" &>/dev/null || {
        echo "Required command not found: $1" >&2
        exit 1
    }
}

require_cmd stow

print_status "Dotfiles directory: ${DOTFILES_DIR}"
cleanup_bad_stow_links
stow_dotfiles
print_success "Dotfiles stowed into ~/.config, ~/.themes, ~/.ssh, and ~/.zshrc"
