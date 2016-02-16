#!/usr/bin/env bash
#
# Install or update command line tools

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

    print_section "Installing tools"

    local tool=1
    if [[ "$1" -eq 0 ]]; then
        tool=0
    else
        confirm "Install tools?"
        tool="$?"
    fi

    if [[ "${tool}" -eq 0 ]]; then
        local -r OS="$(get_os)"
        if [[ "${OS}" == "osx" ]]; then
            ./osx/tools/main.sh "$1"
            exit_on_fail "Error while installing tools"
        elif [[ "${OS}" == "ubuntu" ]]; then
            errexit "Ubuntu not supported yet!" "${E_INVALID_OS}"
        else
            errexit "This OS is not supported yet!" "${E_INVALID_OS}"
        fi
    fi

    print_success "Finished installing tools"
}

main "$1"
