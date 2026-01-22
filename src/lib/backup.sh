#!/bin/bash
#
# backup.sh - Backup functions for qBittorrent
#

# Prevent multiple sourcing
[[ -n "${_BACKUP_SH_LOADED:-}" ]] && return 0
readonly _BACKUP_SH_LOADED=1

readonly BACKUP_FILENAME="qBittorrent-Backup-Linux"

# ============================================================================
# BACKUP FUNCTIONS
# ============================================================================

perform_backup() {
    local backup_dir="${USER_HOME_DIR}${BACKUP_FILENAME}"
    local backup_zip="${USER_HOME_DIR}${BACKUP_FILENAME}.zip"
    local config_dir
    local data_dir
    
    config_dir=$(get_config_dir)
    data_dir=$(get_data_dir)
    
    # Clean up any previous backup attempts
    rm -f "${backup_zip}"
    rm -rf "${backup_dir}/"
    
    # Create directory structure
    mkdir -p "${backup_dir}/qBittorrent/"
    mkdir -p "${backup_dir}/BT_backup/"
    mkdir -p "${backup_dir}/logs/"
    
    # Copy configuration files
    if [[ -d "${config_dir}" ]]; then
        cp -R "${config_dir}"/* "${backup_dir}/qBittorrent/" 2>/dev/null || true
    fi
    
    # Copy torrent metadata
    if [[ -d "${data_dir}/BT_backup" ]]; then
        cp -R "${data_dir}/BT_backup"/* "${backup_dir}/BT_backup/" 2>/dev/null || true
    fi
    
    # Copy logs
    if [[ -d "${data_dir}/logs" ]]; then
        cp -R "${data_dir}/logs"/* "${backup_dir}/logs/" 2>/dev/null || true
    fi
    
    # Verify backup was created successfully
    if [[ ! -f "${backup_dir}/qBittorrent/qBittorrent.conf" ]]; then
        print_error "Failed to backup."
        rm -rf "${backup_dir}/"
        exit 1
    fi
    
    # Create zip archive
    cd "${USER_HOME_DIR}" || exit 1
    zip -r -0 "${BACKUP_FILENAME}.zip" "${BACKUP_FILENAME}/"
    
    # Clean up temporary directory
    rm -rf "${backup_dir}/"
    
    # Set correct ownership
    chown "${CONFIG_USER}:${CONFIG_USER}" "${backup_zip}"
    
    # Display completion message
    clear
    print_success "\nBackup completed.\n"
    echo "Backup saved to:"
    echo -e "$(_bold "${backup_zip}")"
    echo -e "\n\n$(_underline "How to restore? Have this file anywhere on your system and select option 2.")"
    echo -e "$(_underline "All settings, statistics and torrent list will be restored.")"
}

# ============================================================================
# MAIN BACKUP FLOW
# ============================================================================

do_backup() {
    detect_qbittorrent_config
    
    clear
    show_config_info
    
    show_progress "Starting backup..." 3
    
    stop_qbittorrent
    clear
    show_loading 5
    
    perform_backup
    
    wait_for_enter
}
