#!/bin/bash
#
# main.sh - Main entry point for qbittorrent-backup-linux
#
# Usage:
#   ./main.sh           - Interactive menu
#   ./main.sh backup    - Direct backup
#   ./main.sh restore   - Direct restore
#

set -euo pipefail

# ============================================================================
# SCRIPT DIRECTORY DETECTION
# ============================================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"

# ============================================================================
# LOAD MODULES
# ============================================================================

# shellcheck source=lib/colors.sh
source "${LIB_DIR}/colors.sh"

# shellcheck source=lib/utils.sh
source "${LIB_DIR}/utils.sh"

# shellcheck source=lib/checks.sh
source "${LIB_DIR}/checks.sh"

# shellcheck source=lib/config.sh
source "${LIB_DIR}/config.sh"

# shellcheck source=lib/backup.sh
source "${LIB_DIR}/backup.sh"

# shellcheck source=lib/restore.sh
source "${LIB_DIR}/restore.sh"

# ============================================================================
# SETUP
# ============================================================================

# Set up trap for cleanup on exit
trap cleanup EXIT INT TERM

# ============================================================================
# VERSION INFO
# ============================================================================

readonly VERSION="2.0.0"
readonly SCRIPT_NAME="qbittorrent-backup-linux"
readonly INSTALL_DIR="/usr/local/share/qbittorrent-backup-linux"
readonly BIN_LINK="/usr/local/bin/qbittorrent-backup"

show_version() {
    echo "${SCRIPT_NAME} v${VERSION}"
    echo "A simple tool to backup and restore qBittorrent configuration on Linux"
    echo ""
    echo "Usage:"
    echo "  qbittorrent-backup              Interactive menu"
    echo "  qbittorrent-backup backup       Direct backup"
    echo "  qbittorrent-backup restore      Direct restore"
    echo "  qbittorrent-backup --uninstall  Uninstall from system"
    echo "  qbittorrent-backup -h           Show this help"
    echo "  qbittorrent-backup -v           Show version"
}

# ============================================================================
# UNINSTALL
# ============================================================================

do_uninstall() {
    # Check root
    if [[ $EUID -ne 0 ]]; then
        print_error "Uninstall requires root privileges."
        echo "Try: sudo qbittorrent-backup --uninstall"
        exit 1
    fi
    
    print_warning "Uninstalling qbittorrent-backup-linux..."
    
    # Remove symlink
    if [[ -L "${BIN_LINK}" ]]; then
        rm -f "${BIN_LINK}"
        print_success "Removed ${BIN_LINK}"
    fi
    
    # Remove installation directory
    if [[ -d "${INSTALL_DIR}" ]]; then
        rm -rf "${INSTALL_DIR}"
        print_success "Removed ${INSTALL_DIR}"
    fi
    
    print_success "Uninstallation completed!"
}

# ============================================================================
# MENU
# ============================================================================

show_menu() {
    clear
    echo "_________________________________________________________________________"
    echo "|                                                                       |"
    echo "| $(_green "qBittorrent Backup Linux") v${VERSION}                                  |"
    echo "|_______________________________________________________________________|"
    echo "|                                                                       |"
    echo "| 1 - Backup qBittorrent                                                |"
    echo "| 2 - Restore qBittorrent                                               |"
    echo "| 3 - Exit                                                              |"
    echo "|_______________________________________________________________________|"
    echo ""
    echo "Please select your option 1 to 3:"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    # Parse command line arguments
    case "${1:-}" in
        -h|--help)
            show_version
            exit 0
            ;;
        -v|--version)
            echo "${SCRIPT_NAME} v${VERSION}"
            exit 0
            ;;
        --uninstall|-u)
            do_uninstall
            exit 0
            ;;
        backup)
            check_dependencies
            do_backup
            exit 0
            ;;
        restore)
            check_dependencies
            do_restore
            exit 0
            ;;
        "")
            # Interactive mode
            ;;
        *)
            print_error "Unknown option: $1"
            echo ""
            show_version
            exit 1
            ;;
    esac
    
    # Check dependencies before showing menu
    check_dependencies
    
    # Interactive menu loop
    while true; do
        show_menu
        read -r option
        
        case "${option}" in
            1)
                do_backup
                ;;
            2)
                do_restore
                ;;
            3)
                clear
                double_separator
                echo "Exiting..."
                exit 0
                ;;
            *)
                clear
                double_separator
                echo "Invalid Option!"
                sleep 1
                ;;
        esac
    done
}

# Run main function with all arguments
main "$@"
