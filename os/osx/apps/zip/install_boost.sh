#!/usr/bin/env bash
#
# Install Boost

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
declare -r NAME="Boost"
declare -r URL="https://s3-ap-northeast-1.amazonaws.com/0rbital/builds/rokt33r/boost-app/0.4.0-beta.2.zip"

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
    download_zip "${NAME}" "${URL}"
    status_stop_spinner "Finished downloading ${NAME}"
    exit_on_fail "${NAME} download failed" "${E_DOWNLOAD_FAILURE}"
    mv "${NAME}.app" /Applications
    status "${NAME} → /Applications" "${E_COPY_FAILURE}"
    remove_zip "${NAME}"
    status "Removed ${NAME} archive" "${E_REMOVE_FAILURE}"
}

main
