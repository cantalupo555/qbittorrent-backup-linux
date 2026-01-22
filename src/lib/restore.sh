#!/bin/bash
#
# restore.sh - Restore functions for qBittorrent
#

# Prevent multiple sourcing
[[ -n "${_RESTORE_SH_LOADED:-}" ]] && return 0
readonly _RESTORE_SH_LOADED=1

# Use same filename as backup
readonly RESTORE_FILENAME="qBittorrent-Backup-Linux"

# ============================================================================
# BACKUP FILE SEARCH
# ============================================================================

find_backup_file() {
    local trash_file="${USER_HOME_DIR}.local/share/Trash/files/${RESTORE_FILENAME}.zip"
    local trash_info="${USER_HOME_DIR}.local/share/Trash/info/${RESTORE_FILENAME}.zip.trashinfo"
    
    # Remove backup from trash if exists
    rm -f "${trash_file}" 2>/dev/null || true
    rm -f "${trash_info}" 2>/dev/null || true
    
    # Update locate database
    updatedb
    
    # Create temp file for results
    TEMP_DIR=$(create_temp_dir)
    local zip_check="${TEMP_DIR}/zip_check"
    
    # Search for backup file
    plocate "${RESTORE_FILENAME}.zip" > "${zip_check}" 2>/dev/null || true
    
    local file_count
    file_count=$(wc -l < "${zip_check}")
    
    if [[ "${file_count}" -gt 1 ]]; then
        clear
        print_error "Duplicate backup file."
        print_error "Keep only 1 backup file in system.\n"
        cat "${zip_check}"
        exit 1
    elif [[ "${file_count}" -eq 0 ]]; then
        clear
        print_error "${RESTORE_FILENAME}.zip file not found.\n"
        exit 1
    fi
    
    # Return the backup path
    cat "${zip_check}"
}

# ============================================================================
# RESTORE FUNCTIONS
# ============================================================================

perform_restore() {
    local backup_path="$1"
    local backup_dir="${USER_HOME_DIR}${RESTORE_FILENAME}"
    local config_dir
    local data_dir
    
    config_dir=$(get_config_dir)
    data_dir=$(get_data_dir)
    
    # Clean up and extract
    cd "${USER_HOME_DIR}" || exit 1
    rm -rf "${backup_dir}/"
    unzip "${backup_path}"
    chown -R "${CONFIG_USER}:${CONFIG_USER}" "${RESTORE_FILENAME}/"
    
    # Verify extraction
    if [[ ! -f "${backup_dir}/qBittorrent/qBittorrent.conf" ]]; then
        print_error "Failed to restore."
        rm -rf "${backup_dir}/"
        exit 1
    fi
    
    # Restore configuration
    rm -rf "${config_dir}"/*
    cp -R "${backup_dir}/qBittorrent"/* "${config_dir}/"
    chown -R "${CONFIG_USER}:${CONFIG_USER}" "${config_dir}/"
    
    # Restore BT_backup
    if [[ -d "${data_dir}/BT_backup" ]]; then
        rm -rf "${data_dir}/BT_backup"/*
        cp -R "${backup_dir}/BT_backup"/* "${data_dir}/BT_backup/"
        chown -R "${CONFIG_USER}:${CONFIG_USER}" "${data_dir}/BT_backup/"
    fi
    
    # Restore logs
    if [[ -d "${data_dir}/logs" ]]; then
        rm -rf "${data_dir}/logs"/*
        cp -R "${backup_dir}/logs"/* "${data_dir}/logs/"
        chown -R "${CONFIG_USER}:${CONFIG_USER}" "${data_dir}/logs/"
    fi
    
    # Clean up
    rm -rf "${backup_dir}/"
    
    clear
    print_success "\nRestoration completed."
}

# ============================================================================
# MAIN RESTORE FLOW
# ============================================================================

do_restore() {
    detect_qbittorrent_config
    
    clear
    show_config_info
    
    show_progress "Starting restore..." 3
    
    local backup_path
    backup_path=$(find_backup_file)
    
    stop_qbittorrent
    clear
    show_loading 5
    
    perform_restore "${backup_path}"
    
    wait_for_enter
}
