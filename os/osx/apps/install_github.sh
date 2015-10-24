#!/usr/bin/env bash
#
# Install github desktop

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_DOWNLOAD_FAILURE=101
declare -r E_COPY_FAILURE=102
declare -r E_REMOVE_FAILURE=103

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

# Dowload
declare -r NAME="GitHub"
declare -r URL="https://central.github.com/mac/latest"

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
    mv "${NAME}.app" /Applications
    status "${NAME} → /Applications" "${E_COPY_FAILURE}"
    remove_zip "${NAME}"
    status "Removed ${NAME} archive" "${E_REMOVE_FAILURE}"
    print_separator
}

main
