#!/usr/bin/env bash
#
# Install iterm2

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
declare -r NAME="iTerm2"
declare -r URL="http://www.iterm2.com/downloads/stable/iTerm2_v2_0.zip"

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh" \
        && source "./util.sh"

    start_spinner "Downloading ${NAME}"
    download_zip "${NAME}" "${URL}"
    status_stop_spinner "Finished downloading ${NAME}"
    exit_on_fail "${NAME} download failed" "${E_DOWNLOAD_FAILURE}"
    mv "${NAME}.app" /Applications
    status "${NAME} → /Applications" "${E_COPY_FAILURE}"
    remove_zip "${NAME}"
    status "Removed ${NAME} archive" "${E_REMOVE_FAILURE}"
    print_separator
}

main