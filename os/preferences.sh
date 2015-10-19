#!/usr/bin/env bash
#
# Set up preferences

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

    print_section "Setting up preferences"

    local -r OS="$(get_os)"
    if [[ "${OS}" == "osx" ]]; then
        ./osx/preferences/main.sh
    elif [[ "${OS}" == "ununtu" ]]; then
        errexit "Ubuntu not supported yet!" "${E_INVALID_OS}"
    else
        errexit "This OS is not supported yet!" "${E_INVALID_OS}"
    fi

    print_success "Finished setting up preferences"
}

main "$1"
