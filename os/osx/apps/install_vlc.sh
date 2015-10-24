#!/usr/bin/env bash
#
# Install VLC media player

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
declare -r NAME="vlc"
declare -r URL="http://get.videolan.org/vlc/2.2.1/macosx/vlc-2.2.1.dmg"
# Dmg
declare -r PATH="/Volumes/vlc"
declare -r APP="VLC.app"

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
    cp -R "${PATH}/${APP}" /Applications
    status "${NAME} → /Applications" "${E_COPY_FAILURE}"
    remove_dmg "${NAME}" "${PATH}"
    status "Removed ${NAME} archive" "${E_REMOVE_FAILURE}"
    print_separator
}

main
