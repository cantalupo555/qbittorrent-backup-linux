#!/bin/bash
#
# qBittorrent Backup Linux
# A simple script to backup and restore qBittorrent configuration on Linux
#
# Usage:
#   curl -sL qbt.cantalupo.com.br | bash
#   wget -qO- qbt.cantalupo.com.br | bash
#
# URL: https://qbt.cantalupo.com.br
# GitHub: https://github.com/cantalupo555/qbittorrent-backup-linux
#

set -euo pipefail
trap _cleanup EXIT INT TERM

# ============================================================================
# VERSION
# ============================================================================

readonly VERSION="2.1.0"
readonly SCRIPT_NAME="qbittorrent-backup-linux"
readonly BACKUP_FILENAME="qBittorrent-Backup-Linux"

# ============================================================================
# COLORS
# ============================================================================

readonly COLOR_RESET='\033[0m'
readonly COLOR_RED='\033[1;31m'
readonly COLOR_GREEN='\033[1;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_CYAN='\033[1;36m'
readonly COLOR_BOLD='\033[1m'
readonly COLOR_UNDERLINE='\033[4m'
readonly COLOR_FLATPAK='\033[38;5;63m'

_red() { printf '%b%b%b' "${COLOR_RED}" "$1" "${COLOR_RESET}"; }
_green() { printf '%b%b%b' "${COLOR_GREEN}" "$1" "${COLOR_RESET}"; }
_yellow() { printf '%b%b%b' "${COLOR_YELLOW}" "$1" "${COLOR_RESET}"; }
_cyan() { printf '%b%b%b' "${COLOR_CYAN}" "$1" "${COLOR_RESET}"; }
_purple() { printf '%b%b%b' "${COLOR_FLATPAK}" "$1" "${COLOR_RESET}"; }
_bold() { printf '%b%b%b' "${COLOR_BOLD}" "$1" "${COLOR_RESET}"; }
_underline() { printf '%b%b%b' "${COLOR_UNDERLINE}" "$1" "${COLOR_RESET}"; }

print_error() { echo -e "${COLOR_RED}$1${COLOR_RESET}"; }
print_success() { echo -e "${COLOR_GREEN}$1${COLOR_RESET}"; }
print_warning() { echo -e "${COLOR_YELLOW}$1${COLOR_RESET}"; }

# ============================================================================
# GLOBAL VARIABLES
# ============================================================================

TEMP_DIR=""
USER_HOME_DIR=""
IS_FLATPAK=false
FLATPAK_DIR=""

# ============================================================================
# UTILITIES
# ============================================================================

_cleanup() {
    local exit_code=$?
    [[ -n "${TEMP_DIR}" && -d "${TEMP_DIR}" ]] && rm -rf "${TEMP_DIR}"
    exit "${exit_code}"
}

_exists() { command -v "$1" &>/dev/null; }

separator() {
    echo "-------------------------------------------------------------------------"
}

double_separator() {
    separator; separator; separator
}

wait_for_enter() {
    echo ""
    double_separator
    echo "Press ENTER to go back!"
    echo ""
    read -r _
}

show_progress() {
    local msg="$1" count="${2:-3}"
    for ((i=1; i<=count; i++)); do
        print_warning "${msg}"
        sleep 1
    done
}

show_loading() {
    local count="${1:-5}"
    for ((i=1; i<=count; i++)); do
        print_warning ".-.-.-.-.-.-.-.-.-."
        sleep 1
    done
}

stop_qbittorrent() {
    print_warning "Stopping qBittorrent client..."
    killall qbittorrent 2>/dev/null || true
    sleep 2
}

get_data_dir() {
    if [[ "${IS_FLATPAK}" == "true" ]]; then
        echo "${FLATPAK_DIR}data/qBittorrent"
    elif [[ -d "${USER_HOME_DIR}.local/share/qBittorrent/" ]]; then
        echo "${USER_HOME_DIR}.local/share/qBittorrent"
    else
        echo "${USER_HOME_DIR}.local/share/data/qBittorrent"
    fi
}

get_config_dir() {
    if [[ "${IS_FLATPAK}" == "true" ]]; then
        echo "${FLATPAK_DIR}config/qBittorrent"
    else
        echo "${USER_HOME_DIR}.config/qBittorrent"
    fi
}

# ============================================================================
# DEPENDENCY CHECKS
# ============================================================================

check_command() {
    local cmd="$1" pkg="${2:-$1}"
    if ! _exists "${cmd}"; then
        print_error "Please install the '${pkg}' package."
        echo "sudo apt install ${pkg}"
        exit 1
    fi
}

check_qbittorrent() {
    local has_std=false has_flatpak=false
    _exists qbittorrent && has_std=true
    if _exists flatpak; then
        flatpak list 2>/dev/null | grep -q "org.qbittorrent.qBittorrent" && has_flatpak=true
    fi
    if [[ "${has_std}" == "false" && "${has_flatpak}" == "false" ]]; then
        print_error "qBittorrent installation not found."
        echo "Please install qBittorrent via package manager or Flatpak."
        exit 1
    fi
}

check_dependencies() {
    check_command "zip"
    check_command "unzip"
    check_qbittorrent
}

# ============================================================================
# CONFIGURATION DETECTION
# ============================================================================

parse_config_path() {
    local config_path="$1"
    USER_HOME_DIR="${HOME}/"
    if [[ "${config_path}" == *"org.qbittorrent.qBittorrent"* ]]; then
        IS_FLATPAK=true
        FLATPAK_DIR="${HOME}/.var/app/org.qbittorrent.qBittorrent/"
    else
        IS_FLATPAK=false
        FLATPAK_DIR=""
    fi
}

select_installation() {
    local -a configs=("$@")
    local choice max_choice=${#configs[@]}
    
    print_success "Found multiple qBittorrent installations:\n"
    for i in "${!configs[@]}"; do
        local num=$((i + 1))
        if echo "${configs[$i]}" | grep -q "org.qbittorrent.qBittorrent"; then
            echo -e "$(_purple "${num} - [Flatpak]") ${configs[$i]}"
        else
            echo -e "$(_cyan "${num} - [Default]") ${configs[$i]}"
        fi
    done
    echo -e "$(_red "$((max_choice + 1)) - Exit")"
    
    print_warning "\nWhich installation do you want to use? (1-$((max_choice + 1)))"
    read -r choice
    
    if ! [[ "${choice}" =~ ^[0-9]+$ ]]; then
        echo "Invalid choice. Exiting..."; exit 1
    fi
    if [[ "${choice}" -eq $((max_choice + 1)) ]]; then
        echo "Exiting..."; exit 0
    elif [[ "${choice}" -ge 1 && "${choice}" -le "${max_choice}" ]]; then
        parse_config_path "${configs[$((choice - 1))]}"
    else
        echo "Invalid choice. Exiting..."; exit 1
    fi
}

detect_qbittorrent_config() {
    local config_paths=()
    local home_dir="${HOME}"

    echo "Detecting qBittorrent configuration..."

    [[ -f "${home_dir}/.config/qBittorrent/qBittorrent.conf" ]] && \
        config_paths+=("${home_dir}/.config/qBittorrent/qBittorrent.conf")

    [[ -f "${home_dir}/.var/app/org.qbittorrent.qBittorrent/config/qBittorrent/qBittorrent.conf" ]] && \
        config_paths+=("${home_dir}/.var/app/org.qbittorrent.qBittorrent/config/qBittorrent/qBittorrent.conf")

    if [[ ${#config_paths[@]} -eq 0 ]]; then
        print_error "qBittorrent configuration not found."
        echo "Launch qBittorrent client before running this script."
        exit 1
    fi
    
    if [[ ${#config_paths[@]} -eq 1 ]]; then
        parse_config_path "${config_paths[0]}"
    else
        select_installation "${config_paths[@]}"
    fi
}

show_config_info() {
    echo "Selected directory: ${USER_HOME_DIR}"
    [[ "${IS_FLATPAK}" == "true" ]] && echo -e "Flatpak directory: ${FLATPAK_DIR}\n"
    sleep 2
}

# ============================================================================
# BACKUP
# ============================================================================

perform_backup() {
    local backup_dir="${USER_HOME_DIR}${BACKUP_FILENAME}"
    local backup_zip="${USER_HOME_DIR}${BACKUP_FILENAME}.zip"
    local config_dir data_dir
    config_dir=$(get_config_dir)
    data_dir=$(get_data_dir)
    
    rm -f "${backup_zip}"
    rm -rf "${backup_dir}/"
    mkdir -p "${backup_dir}/qBittorrent/" "${backup_dir}/BT_backup/" "${backup_dir}/logs/"
    
    [[ -d "${config_dir}" ]] && cp -R "${config_dir}"/* "${backup_dir}/qBittorrent/" 2>/dev/null || true
    [[ -d "${data_dir}/BT_backup" ]] && cp -R "${data_dir}/BT_backup"/* "${backup_dir}/BT_backup/" 2>/dev/null || true
    [[ -d "${data_dir}/logs" ]] && cp -R "${data_dir}/logs"/* "${backup_dir}/logs/" 2>/dev/null || true
    
    if [[ ! -f "${backup_dir}/qBittorrent/qBittorrent.conf" ]]; then
        print_error "Failed to backup."
        rm -rf "${backup_dir}/"
        exit 1
    fi
    
    cd "${USER_HOME_DIR}" || exit 1
    zip -r -0 "${BACKUP_FILENAME}.zip" "${BACKUP_FILENAME}/"
    rm -rf "${backup_dir}/"

    clear
    print_success "\nBackup completed.\n"
    echo "Backup saved to:"
    echo -e "$(_bold "${backup_zip}")"
    echo -e "\n\n$(_underline "How to restore? Have this file anywhere on your system and select option 2.")"
    echo -e "$(_underline "All settings, statistics and torrent list will be restored.")"
}

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

# ============================================================================
# RESTORE
# ============================================================================

find_backup_file() {
    local home_dir="${HOME}"
    local current_dir
    local -a backup_files=()
    local -a unique_files=()
    declare -A seen_files=()

    current_dir=$(pwd)

    local trash_file="${USER_HOME_DIR}.local/share/Trash/files/${BACKUP_FILENAME}.zip"
    local trash_info="${USER_HOME_DIR}.local/share/Trash/info/${BACKUP_FILENAME}.zip.trashinfo"
    rm -f "${trash_file}" "${trash_info}" 2>/dev/null || true

    while IFS= read -r file_path; do
        [[ -n "${file_path}" ]] && backup_files+=("${file_path}")
    done < <(find "${home_dir}" -type f -name "${BACKUP_FILENAME}.zip" 2>/dev/null)

    if [[ "${current_dir}" != "${home_dir}" && "${current_dir}" != "${home_dir}/"* ]]; then
        while IFS= read -r file_path; do
            [[ -n "${file_path}" ]] && backup_files+=("${file_path}")
        done < <(find "${current_dir}" -type f -name "${BACKUP_FILENAME}.zip" 2>/dev/null)
    fi

    for file_path in "${backup_files[@]}"; do
        if [[ -z "${seen_files["${file_path}"]+_}" ]]; then
            seen_files["${file_path}"]=1
            unique_files+=("${file_path}")
        fi
    done

    if [[ ${#unique_files[@]} -gt 1 ]]; then
        clear
        print_error "Duplicate backup file."
        print_error "Keep only 1 backup file in system.\n"
        printf '%s\n' "${unique_files[@]}"
        exit 1
    elif [[ ${#unique_files[@]} -eq 0 ]]; then
        clear
        print_error "${BACKUP_FILENAME}.zip file not found.\n"
        exit 1
    fi

    echo "${unique_files[0]}"
}

perform_restore() {
    local backup_path="$1"
    local backup_dir="${USER_HOME_DIR}${BACKUP_FILENAME}"
    local config_dir data_dir
    config_dir=$(get_config_dir)
    data_dir=$(get_data_dir)
    
    cd "${USER_HOME_DIR}" || exit 1
    rm -rf "${backup_dir}/"
    unzip "${backup_path}"

    if [[ ! -f "${backup_dir}/qBittorrent/qBittorrent.conf" ]]; then
        print_error "Failed to restore."
        rm -rf "${backup_dir}/"
        exit 1
    fi
    
    rm -rf "${config_dir}"/*
    cp -R "${backup_dir}/qBittorrent"/* "${config_dir}/"

    if [[ -d "${data_dir}/BT_backup" ]]; then
        rm -rf "${data_dir}/BT_backup"/*
        cp -R "${backup_dir}/BT_backup"/* "${data_dir}/BT_backup/"
    fi

    if [[ -d "${data_dir}/logs" ]]; then
        rm -rf "${data_dir}/logs"/*
        cp -R "${backup_dir}/logs"/* "${data_dir}/logs/"
    fi
    
    rm -rf "${backup_dir}/"
    clear
    print_success "\nRestoration completed."
}

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

# ============================================================================
# MENU
# ============================================================================

show_header() {
    echo "-------------------------- qbt.cantalupo.com.br --------------------------"
    echo "  A simple script to backup and restore qBittorrent on Linux"
    separator
    echo "Version            : v${VERSION}"
    echo "GitHub             : https://github.com/cantalupo555/qbittorrent-backup-linux"
    separator
}

show_menu() {
    clear
    show_header
    local menu_title="qBittorrent Backup Linux v${VERSION}"

    echo ""
    echo "_________________________________________________________________________"
    echo "|                                                                       |"
    printf '| %b%-69s%b |\n' "${COLOR_GREEN}" "${menu_title}" "${COLOR_RESET}"
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
    check_dependencies
    
    # Redirect stdin from /dev/tty for interactive input when piped
    exec < /dev/tty
    
    while true; do
        show_menu
        read -r option
        case "${option}" in
            1) do_backup ;;
            2) do_restore ;;
            3) clear; double_separator; echo "Exiting..."; exit 0 ;;
            *) clear; double_separator; echo "Invalid Option!"; sleep 1 ;;
        esac
    done
}

main "$@"
