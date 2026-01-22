#!/bin/bash
#
# config.sh - qBittorrent configuration detection
#

# Prevent multiple sourcing
[[ -n "${_CONFIG_SH_LOADED:-}" ]] && return 0
readonly _CONFIG_SH_LOADED=1

# ============================================================================
# CONFIGURATION PARSING
# ============================================================================

parse_config_path() {
    local config_path="$1"
    
    # Extract user home directory
    USER_HOME_DIR=$(echo "${config_path}" | sed 's|\(/home/[^/]*\)/.*|\1/|')
    CONFIG_USER=$(echo "${USER_HOME_DIR}" | cut -d'/' -f3)
    
    # Check if it's a Flatpak installation
    if echo "${config_path}" | grep -q "org.qbittorrent.qBittorrent"; then
        IS_FLATPAK=true
        FLATPAK_DIR=$(echo "${config_path}" | sed 's|\(.*org\.qbittorrent\.qBittorrent\).*|\1/|')
    else
        IS_FLATPAK=false
        FLATPAK_DIR=""
    fi
}

# ============================================================================
# INSTALLATION SELECTION
# ============================================================================

select_installation() {
    local -a configs=("$@")
    local choice
    local max_choice=${#configs[@]}
    
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
    
    # Validate input
    if ! [[ "${choice}" =~ ^[0-9]+$ ]]; then
        clear
        echo "Invalid choice. Please enter a number."
        echo "Exiting..."
        exit 1
    fi
    
    if [[ "${choice}" -eq $((max_choice + 1)) ]]; then
        clear
        echo "You selected to exit."
        echo "Exiting..."
        exit 0
    elif [[ "${choice}" -ge 1 && "${choice}" -le "${max_choice}" ]]; then
        parse_config_path "${configs[$((choice - 1))]}"
    else
        clear
        echo "Invalid choice."
        echo "You need to choose between 1 and $((max_choice + 1))."
        echo "Exiting..."
        exit 1
    fi
}

# ============================================================================
# MAIN DETECTION FUNCTION
# ============================================================================

detect_qbittorrent_config() {
    local config_paths=()
    
    echo "Please wait."
    echo "Detecting qBittorrent client configuration..."
    print_error "This may take a few seconds."
    
    # Update the locate database
    updatedb
    
    clear
    
    # Search for qBittorrent configuration
    mapfile -t config_paths < <(plocate "*config/qBittorrent/qBittorrent.conf" 2>/dev/null || true)
    
    if [[ ${#config_paths[@]} -eq 0 ]]; then
        print_error "qBittorrent configuration not found."
        echo "Launch qBittorrent client before running this script."
        exit 1
    fi
    
    if [[ ${#config_paths[@]} -eq 1 ]]; then
        # Single installation found
        parse_config_path "${config_paths[0]}"
    else
        # Multiple installations - let user choose
        select_installation "${config_paths[@]}"
    fi
}

# Display detected configuration
show_config_info() {
    echo "Selected directory: ${USER_HOME_DIR}"
    echo "Selected user: ${CONFIG_USER}"
    if [[ "${IS_FLATPAK}" == "true" ]]; then
        echo -e "Flatpak directory: ${FLATPAK_DIR}\n"
    fi
    sleep 2
}
