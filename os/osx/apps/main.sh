#!/usr/bin/env bash
#
# Install apps directly

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_INSTALL_FAILURE=101

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

declare -r -a APPSTORE=(
    'xcode'
    'keynote'
    'pages'
    'numbers'
)

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

list_appstore() {
    for i in "${APPSTORE[@]}"; do
        if [[ -n "$i" ]]; then
            _print_info "Install $i from the appstore"
        fi
    done
}

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh"

    ./cask.sh
    exit_on_fail "Homebrew app install failed"

    list_appstore
}

main "$1"
