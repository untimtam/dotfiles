#!/usr/bin/env bash
#
# OS Specific initialization for fresh install

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

    print_section "Running initialization"

    local -r OS="$(get_os)"
    if [[ "${OS}" == "osx" ]]; then
        ./osx/tools/install_xcode.sh
    elif [[ "${OS}" == "ununtu" ]]; then
        errexit "Ubuntu not supported yet!" "${E_INVALID_OS}"
    else
        errexit "This OS is not supported yet!" "${E_INVALID_OS}"
    fi

    print_success "Finished running initialization"
}

main "$1"
