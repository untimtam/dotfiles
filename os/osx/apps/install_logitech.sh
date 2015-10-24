#!/usr/bin/env bash
#
# Install

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_DOWNLOAD_FAILURE=101

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

# Dowload
declare -r NAME="logitechdriver"
declare -r URL="http://www.logitech.com/pub/techsupport/gaming/LogitechSetup_8.58.40.zip"

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh" \
        && source "./util.sh"

    download_zip "${NAME}" "${URL}"
    status "Downloading ${NAME}" "${E_DOWNLOAD_FAILURE}"
    print_info "${NAME} needs to be installed manually"
    print_separator
}

main
