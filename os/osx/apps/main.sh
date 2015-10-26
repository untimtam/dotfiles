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
    'keynote'
    'pages'
    'numbers'

    'dash'
    'pocket'
    'slack'
    'pushbullet'

    'evernote'
    'onenote'

    'encrypto'
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
            print_info "Please install $i from the appstore!"
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

    # TODO: switch to homebrew cask when app move is fully supported
    # TODO: verify links
    # mkcd temp directory?
    # TODO: global variable with relative path??
    declare -a INSTALL_FILES=(dmg/install_*.sh)
    INSTALL_FILES+=(zip/install_*.sh)
    install_apps
    exit_on_fail "App install failed"

    if [[ "$1" -eq 0 ]]; then
        declare -r -a MAN_INSTALL_FILES=(manual/install_*.sh)
        manual_apps
        exit_on_fail "Manual app install failed"
    else
        confirm "Install manual apps (cant check if they are installed already)?"
        if status_code; then
            manual_apps
            exit_on_fail "Manual app install failed"
        fi
    fi

    ./homebrew_apps.sh
    exit_on_fail "Homebrew app install failed"

    list_appstore
}

main "$1"
