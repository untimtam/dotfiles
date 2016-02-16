#!/usr/bin/env bash
#
# Verify that everything worked correctly

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

    print_section "Running verifications"

    local -r OS="$(get_os)"
    if [[ "${OS}" == "osx" ]]; then
        print_info "Run OSX tests"
    elif [[ "${OS}" == "ubuntu" ]]; then
        errexit "Ubuntu not supported yet!" "${E_INVALID_OS}"
    else
        errexit "This OS is not supported yet!" "${E_INVALID_OS}"
    fi

    print_success "Finished running verifications"
}

main "$1"
