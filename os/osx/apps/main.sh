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

    'pocket'
)

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

install_apps() {
    for i in "${INSTALL_FILES[@]}"; do
        if [[ (-n "$i") && (-e "./$i") ]]; then
            ./"$i"
            status "Finished $i" "${E_INSTALL_FAILURE}"
            print_separator
        fi
    done
}

manual_apps() {
    for i in "${MAN_INSTALL_FILES[@]}"; do
        if [[ (-n "$i") && (-e "./$i") ]]; then
            ./"$i"
            status "Finished $i" "${E_INSTALL_FAILURE}"
            print_separator
        fi
    done
}

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

    declare -a INSTALL_FILES=(dmg/install_*.sh)
    INSTALL_FILES+=(zip/install_*.sh)
    install_apps
    exit_on_fail "App install failed"

    ./cask.sh
    exit_on_fail "Homebrew app install failed"

    list_appstore
}

main "$1"
