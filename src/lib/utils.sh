#!/bin/bash
#
# utils.sh - Utility functions for qbittorrent-backup-linux
#

# Prevent multiple sourcing
[[ -n "${_UTILS_SH_LOADED:-}" ]] && return 0
readonly _UTILS_SH_LOADED=1

# ============================================================================
# GLOBAL VARIABLES
# ============================================================================

TEMP_DIR=""
USER_HOME_DIR=""
CONFIG_USER=""
IS_FLATPAK=false
FLATPAK_DIR=""

# ============================================================================
# CLEANUP
# ============================================================================

# Cleanup function for trap
cleanup() {
    local exit_code=$?
    if [[ -n "${TEMP_DIR}" && -d "${TEMP_DIR}" ]]; then
        rm -rf "${TEMP_DIR}"
    fi
    exit "${exit_code}"
}

# ============================================================================
# UI HELPERS
# ============================================================================

# Print horizontal separator
separator() {
    printf "%-75s\n" "-" | sed 's/\s/-/g'
}

# Print double separator
double_separator() {
    echo "-------------------------------------------------------------------------"
    echo "-------------------------------------------------------------------------"
    echo "-------------------------------------------------------------------------"
}

# Wait for user to press ENTER
wait_for_enter() {
    echo ""
    double_separator
    echo "Press ENTER to go back!"
    echo ""
    read -r _
}

# Display progress animation
show_progress() {
    local message="$1"
    local count="${2:-3}"
    local delay="${3:-1}"
    
    for ((i=1; i<=count; i++)); do
        print_warning "${message}"
        sleep "${delay}"
    done
}

# Show loading dots animation
show_loading() {
    local count="${1:-5}"
    local delay="${2:-1}"
    
    for ((i=1; i<=count; i++)); do
        print_warning ".-.-.-.-.-.-.-.-.-."
        sleep "${delay}"
    done
}

# ============================================================================
# SYSTEM HELPERS
# ============================================================================

# Check if command exists
_exists() {
    local cmd="$1"
    command -v "${cmd}" &>/dev/null
}

# Stop qBittorrent client
stop_qbittorrent() {
    print_warning "Stopping qBittorrent client..."
    killall qbittorrent 2>/dev/null || true
    sleep 2
}

# Create temporary directory
create_temp_dir() {
    TEMP_DIR=$(mktemp -d)
    echo "${TEMP_DIR}"
}

# ============================================================================
# PATH HELPERS
# ============================================================================

# Get qBittorrent data directory based on installation type
get_data_dir() {
    if [[ "${IS_FLATPAK}" == "true" ]]; then
        echo "${FLATPAK_DIR}data/qBittorrent"
    elif [[ -d "${USER_HOME_DIR}.local/share/qBittorrent/" ]]; then
        echo "${USER_HOME_DIR}.local/share/qBittorrent"
    else
        echo "${USER_HOME_DIR}.local/share/data/qBittorrent"
    fi
}

# Get qBittorrent config directory based on installation type
get_config_dir() {
    if [[ "${IS_FLATPAK}" == "true" ]]; then
        echo "${FLATPAK_DIR}config/qBittorrent"
    else
        echo "${USER_HOME_DIR}.config/qBittorrent"
    fi
}
