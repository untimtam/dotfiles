#!/usr/bin/env bash
#
# Install sublime

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_APT_FAILURE=101
declare -r E_KEY_FAILURE=102
declare -r E_UPDATE_FAILURE=103

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

declare -r NAME='sublime-text-installer'

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
        add_ppa 'webupd8team/sublime-text-3' >> "${ERROR_FILE}" 2>&1 > /dev/null
        status "" "${E_KEY_FAILURE}"

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
