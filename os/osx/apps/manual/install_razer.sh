#!/usr/bin/env bash
#
# Install Razer Synapse

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_DOWNLOAD_FAILURE=101
declare -r E_MV_FAILURE=102

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

# Dowload
declare -r NAME="razersynapse"
declare -r URL="http://rzr.to/synapse-mac-download"

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../../script/utils.sh" \
        && source "../util.sh"

    if [[ -e "/Applications/${NAME}.app" ]]; then
        print_success "${NAME} already installed"
        return 0
    fi

    start_spinner "Downloading ${NAME}"
    download "${NAME}.dmg" "${URL}"
    status_stop_spinner "Finished downloading ${NAME}"
    exit_on_fail "${NAME} download failed" "${E_DOWNLOAD_FAILURE}"
    mv "${NAME}.dmg" "${HOME}/Downloads"
    exit_on_fail "Coudlnt move ${NAME}.dmg to ${HOME}/Downloads" "${E_MV_FAILURE}"
    _print_info "${NAME} needs to be installed manually (from ${HOME}/Downloads)"
}

main
