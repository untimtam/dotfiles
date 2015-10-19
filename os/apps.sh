#!/usr/bin/env bash
#
# Install or update apps

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_INVALID_OS=101

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../script/utils.sh"

    print_section "Installing apps"

    local -r OS="$(get_os)"
    if [[ "${OS}" == "osx" ]]; then
        ./osx/apps/main.sh
        exit_on_fail "Error while installing apps"
    elif [[ "${OS}" == "ununtu" ]]; then
        errexit "Ubuntu not supported yet!" "${E_INVALID_OS}"
    else
        errexit "This OS is not supported yet!" "${E_INVALID_OS}"
    fi

    print_success "Finished installing apps"
}

main "$1"
