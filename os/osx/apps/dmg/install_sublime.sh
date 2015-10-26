#!/usr/bin/env bash
#
# Install sublime

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
declare -r NAME="Sublime Text"
declare -r URL="http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%20Build%203083.dmg"
# Dmg
declare -r VPATH="/Volumes/Sublime Text"
declare -r APP="Sublime Text.app"

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh" \
        && source "../util.sh"

    if [[ -e "/Applications/${NAME}.app" ]]; then
        print_success "${NAME} already installed"
        return 0
    fi

    start_spinner "Downloading ${NAME}"
    download_dmg "${NAME}" "${URL}"
    status_stop_spinner "Finished downloading ${NAME}"
    exit_on_fail "${NAME} download failed" "${E_DOWNLOAD_FAILURE}"
    cp -R "${VPATH}/${APP}" /Applications
    status "${NAME} → /Applications" "${E_COPY_FAILURE}"
    remove_dmg "${NAME}" "${VPATH}"
    status "Removed ${NAME} archive" "${E_REMOVE_FAILURE}"
}

main
