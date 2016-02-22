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

    local pref=1
    if [[ "$1" -eq 0 ]]; then
        pref=0
    else
        confirm "Set preferences?"
        pref="$?"
    fi

    if [[ "${pref}" -eq 0 ]]; then
        local -r OS="$(get_os)"
        if [[ "${OS}" == "osx" ]]; then
            ./osx/preferences/main.sh "$1"
            exit_on_fail "Error while setting preferences"
        elif [[ "${OS}" == "ubuntu" ]]; then
            ./ubuntu/preferences/main.sh "$1"
            exit_on_fail "Error while setting preferences"
        else
            errexit "This OS is not supported yet!" "${E_INVALID_OS}"
        fi
    fi

    print_success "Finished setting up preferences"
}

main "$1"
