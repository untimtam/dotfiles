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

    local app=1
    if [[ "$1" -eq 0 ]]; then
        app=0
    else
        confirm "Install apps?"
        app="$?"
    fi

    if [[ "${app}" -eq 0 ]]; then
        local -r OS="$(get_os)"
        if [[ "${OS}" == "osx" ]]; then
            ./osx/apps/main.sh "$1"
            exit_on_fail "Error while installing apps"
        elif [[ "${OS}" == "ubuntu" ]]; then
            ./ubuntu/apps/main.sh "$1"
            exit_on_fail "Error while installing apps"
        else
            errexit "This OS is not supported yet!" "${E_INVALID_OS}"
        fi
    fi

    print_success "Finished installing apps"
}

main "$1"
