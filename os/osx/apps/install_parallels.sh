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

    download_dmg "${NAME}" "${URL}"
    status "Downloading ${NAME}" "${E_DOWNLOAD_FAILURE}"
    print_info "${NAME} needs to be installed manually"
    print_separator
}

main
