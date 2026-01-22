#!/bin/bash
#
# colors.sh - ANSI color constants and color printing functions
#

# Prevent multiple sourcing
[[ -n "${_COLORS_SH_LOADED:-}" ]] && return 0
readonly _COLORS_SH_LOADED=1

# ============================================================================
# ANSI COLOR CODES
# ============================================================================

readonly COLOR_RESET='\033[0m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_PURPLE='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_WHITE='\033[0;37m'

# Bold variants
readonly COLOR_BOLD='\033[1m'
readonly COLOR_BOLD_RED='\033[1;31m'
readonly COLOR_BOLD_GREEN='\033[1;32m'
readonly COLOR_BOLD_YELLOW='\033[1;33m'
readonly COLOR_BOLD_BLUE='\033[1;34m'
readonly COLOR_BOLD_PURPLE='\033[1;35m'
readonly COLOR_BOLD_CYAN='\033[1;36m'

# Special
readonly COLOR_UNDERLINE='\033[4m'
readonly COLOR_FLATPAK='\033[38;5;63m'

# ============================================================================
# COLOR PRINTING FUNCTIONS
# ============================================================================

_red() {
    printf '%b%b%b' "${COLOR_BOLD_RED}" "$1" "${COLOR_RESET}"
}

_green() {
    printf '%b%b%b' "${COLOR_BOLD_GREEN}" "$1" "${COLOR_RESET}"
}

_yellow() {
    printf '%b%b%b' "${COLOR_BOLD_YELLOW}" "$1" "${COLOR_RESET}"
}

_blue() {
    printf '%b%b%b' "${COLOR_BOLD_BLUE}" "$1" "${COLOR_RESET}"
}

_cyan() {
    printf '%b%b%b' "${COLOR_BOLD_CYAN}" "$1" "${COLOR_RESET}"
}

_purple() {
    printf '%b%b%b' "${COLOR_FLATPAK}" "$1" "${COLOR_RESET}"
}

_bold() {
    printf '%b%b%b' "${COLOR_BOLD}" "$1" "${COLOR_RESET}"
}

_underline() {
    printf '%b%b%b' "${COLOR_UNDERLINE}" "$1" "${COLOR_RESET}"
}

# Print colored message with newline
print_msg() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${COLOR_RESET}"
}

print_error() {
    print_msg "${COLOR_BOLD_RED}" "$1"
}

print_success() {
    print_msg "${COLOR_BOLD_GREEN}" "$1"
}

print_warning() {
    print_msg "${COLOR_BOLD_YELLOW}" "$1"
}

print_info() {
    print_msg "${COLOR_BOLD_CYAN}" "$1"
}
