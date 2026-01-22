#!/bin/bash
#
# install.sh - Installer for qbittorrent-backup-linux
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/USER/qbittorrent-backup-linux/main/install.sh | bash
#   wget -qO- https://raw.githubusercontent.com/USER/qbittorrent-backup-linux/main/install.sh | bash
#
# Or run locally:
#   ./install.sh
#   ./install.sh --uninstall
#

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly INSTALL_DIR="/usr/local/share/qbittorrent-backup-linux"
readonly BIN_LINK="/usr/local/bin/qbittorrent-backup"
readonly REPO_URL="https://github.com/USER/qbittorrent-backup-linux"
readonly BRANCH="main"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly CYAN='\033[0;36m'
readonly RESET='\033[0m'

# ============================================================================
# HELPERS
# ============================================================================

_red() { printf '%b%b%b\n' "${RED}" "$1" "${RESET}"; }
_green() { printf '%b%b%b\n' "${GREEN}" "$1" "${RESET}"; }
_yellow() { printf '%b%b%b\n' "${YELLOW}" "$1" "${RESET}"; }
_cyan() { printf '%b%b%b\n' "${CYAN}" "$1" "${RESET}"; }

_exists() { command -v "$1" &>/dev/null; }

_error() {
    _red "Error: $1"
    exit 1
}

# ============================================================================
# CHECKS
# ============================================================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
        _error "This script must be run as root. Try: sudo $0"
    fi
}

check_dependencies() {
    local missing=()
    
    for cmd in zip unzip plocate; do
        if ! _exists "$cmd"; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        _yellow "Missing dependencies: ${missing[*]}"
        _cyan "Installing dependencies..."
        
        if _exists apt; then
            apt update -qq
            apt install -y "${missing[@]}"
        elif _exists dnf; then
            dnf install -y "${missing[@]}"
        elif _exists pacman; then
            pacman -Sy --noconfirm "${missing[@]}"
        else
            _error "Could not install dependencies. Please install manually: ${missing[*]}"
        fi
    fi
}

# ============================================================================
# INSTALL
# ============================================================================

install_from_local() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    _cyan "Installing from local directory..."
    
    # Create installation directory
    mkdir -p "${INSTALL_DIR}"
    
    # Copy files
    cp -R "${script_dir}/src" "${INSTALL_DIR}/"
    chmod +x "${INSTALL_DIR}/src/main.sh"
    chmod +x "${INSTALL_DIR}/src/lib/"*.sh
    
    # Create symlink
    ln -sf "${INSTALL_DIR}/src/main.sh" "${BIN_LINK}"
    
    _green "Installation completed!"
    echo ""
    echo "Usage:"
    echo "  sudo qbittorrent-backup          # Interactive menu"
    echo "  sudo qbittorrent-backup backup   # Direct backup"
    echo "  sudo qbittorrent-backup restore  # Direct restore"
}

install_from_github() {
    _cyan "Installing from GitHub..."
    
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Cleanup on exit
    trap "rm -rf ${temp_dir}" EXIT
    
    # Download repository
    if _exists git; then
        git clone --depth 1 --branch "${BRANCH}" "${REPO_URL}.git" "${temp_dir}/repo"
    elif _exists curl; then
        curl -sL "${REPO_URL}/archive/${BRANCH}.tar.gz" | tar xz -C "${temp_dir}"
        mv "${temp_dir}"/qbittorrent-backup-linux-* "${temp_dir}/repo"
    elif _exists wget; then
        wget -qO- "${REPO_URL}/archive/${BRANCH}.tar.gz" | tar xz -C "${temp_dir}"
        mv "${temp_dir}"/qbittorrent-backup-linux-* "${temp_dir}/repo"
    else
        _error "git, curl, or wget is required to download the repository"
    fi
    
    # Create installation directory
    mkdir -p "${INSTALL_DIR}"
    
    # Copy files
    cp -R "${temp_dir}/repo/src" "${INSTALL_DIR}/"
    chmod +x "${INSTALL_DIR}/src/main.sh"
    chmod +x "${INSTALL_DIR}/src/lib/"*.sh
    
    # Create symlink
    ln -sf "${INSTALL_DIR}/src/main.sh" "${BIN_LINK}"
    
    _green "Installation completed!"
    echo ""
    echo "Usage:"
    echo "  sudo qbittorrent-backup          # Interactive menu"
    echo "  sudo qbittorrent-backup backup   # Direct backup"
    echo "  sudo qbittorrent-backup restore  # Direct restore"
}

# ============================================================================
# UNINSTALL
# ============================================================================

uninstall() {
    _yellow "Uninstalling qbittorrent-backup-linux..."
    
    # Remove symlink
    if [[ -L "${BIN_LINK}" ]]; then
        rm -f "${BIN_LINK}"
        _green "Removed ${BIN_LINK}"
    fi
    
    # Remove installation directory
    if [[ -d "${INSTALL_DIR}" ]]; then
        rm -rf "${INSTALL_DIR}"
        _green "Removed ${INSTALL_DIR}"
    fi
    
    _green "Uninstallation completed!"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    echo ""
    _cyan "=========================================="
    _cyan " qBittorrent Backup Linux - Installer"
    _cyan "=========================================="
    echo ""
    
    check_root
    
    case "${1:-}" in
        --uninstall|-u)
            uninstall
            exit 0
            ;;
        --help|-h)
            echo "Usage:"
            echo "  $0              Install qbittorrent-backup-linux"
            echo "  $0 --uninstall  Uninstall qbittorrent-backup-linux"
            echo ""
            echo "Or install via curl:"
            echo "  curl -sL <URL>/install.sh | sudo bash"
            exit 0
            ;;
    esac
    
    check_dependencies
    
    # Check if running from local directory with src folder
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    if [[ -d "${script_dir}/src" ]]; then
        install_from_local
    else
        install_from_github
    fi
}

main "$@"
