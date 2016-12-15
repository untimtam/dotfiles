#!/usr/bin/env bash
#
# Install chrome

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_APT_FAILURE=101
declare -r E_KEY_FAILURE=102
declare -r E_SOURCE_FAILURE=103
declare -r E_UPDATE_FAILURE=104

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

declare -r NAME='google-chrome-stable'

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh" \
        && source "../util.sh"

    if ! package_is_installed "${NAME}"; then
        add_key 'https://dl-ssl.google.com/linux/linux_signing_key.pub' >> "${ERROR_FILE}" 2>&1 > /dev/null
        status "" "${E_KEY_FAILURE}"

        add_to_source_list 'http://dl.google.com/linux/chrome/deb/ stable main' 'google.list' >> "${ERROR_FILE}" 2>&1 > /dev/null
        status "" "${E_SOURCE_FAILURE}"

        start_spinner "Updating apt"
        update >> "${ERROR_FILE}" 2>&1 > /dev/null
        status_stop_spinner "Finished updating apt"
        exit_on_fail "Update failed" "${E_UPDATE_FAILURE}"
    fi

    start_spinner "Installing ${NAME}"
    install_package "${NAME}"
    status_stop_spinner "Finished installing ${NAME}"
    exit_on_fail "${NAME} installation failed" "${E_APT_FAILURE}"
}

main "$1"
