#!/bin/bash
#
# checks.sh - Dependency and permission checks
#

# Prevent multiple sourcing
[[ -n "${_CHECKS_SH_LOADED:-}" ]] && return 0
readonly _CHECKS_SH_LOADED=1

# ============================================================================
# PERMISSION CHECKS
# ============================================================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Run failed. Try again using:"
        echo "sudo ./qbittorrent-backup-linux.sh"
        exit 1
    fi
}

# ============================================================================
# DEPENDENCY CHECKS
# ============================================================================

check_command() {
    local cmd="$1"
    local package="${2:-$1}"
    
    if ! _exists "${cmd}"; then
        print_error "Please install the '${package}' package."
        echo "sudo apt install ${package}"
        exit 1
    fi
}

check_qbittorrent_installed() {
    local has_standard=false
    local has_flatpak=false
    
    if _exists qbittorrent; then
        has_standard=true
    fi
    
    if _exists flatpak; then
        if flatpak list 2>/dev/null | grep -q "org.qbittorrent.qBittorrent"; then
            has_flatpak=true
        fi
    fi
    
    if [[ "${has_standard}" == "false" && "${has_flatpak}" == "false" ]]; then
        print_error "qBittorrent installation not found."
        echo "Please install qBittorrent via package manager or Flatpak."
        exit 1
    fi
}

# ============================================================================
# MAIN CHECK FUNCTION
# ============================================================================

check_dependencies() {
    check_root
    check_command "zip"
    check_command "unzip"
    check_command "plocate"
    check_qbittorrent_installed
}
