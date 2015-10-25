#!/usr/bin/env bash
#
# Install Parallels Desktop 11

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_DOWNLOAD_FAILURE=101

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

# Dowload
declare -r NAME="parallels"
declare -r URL="http://www.parallels.com/directdownload/pd11/"

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh" \
        && source "./util.sh"

    start_spinner "Downloading ${NAME}"
    download_dmg "${NAME}" "${URL}"
    status_stop_spinner "Finished downloading ${NAME}"
    exit_on_fail "${NAME} download failed" "${E_DOWNLOAD_FAILURE}"
    print_info "${NAME} needs to be installed manually"
    print_separator
}

main