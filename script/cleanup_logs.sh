#!/usr/bin/env bash
#
# Clean up logs

remove_logs() {
    if [[ -e "${ERROR_FILE}" ]]; then
        rm -rf "${ERROR_FILE}"
        status_no_exit "Removed error log"
    fi
    if [[ -e "${INFO_FILE}" ]]; then
        rm -rf "${INFO_FILE}"
        status_no_exit "removed info log"
    fi
}

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "utils.sh"

    remove_logs
}

main
