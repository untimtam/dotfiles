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

declare -r -a INSTALL_FILES=(install_*.sh)
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
        if [[ (-n "$i") && (-e "$i") ]]; then
            ./$i
            status "Installed $i" "${E_INSTALL_FAILURE}"
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
    install_apps
    exit_on_fail "App install failed"

    ./homebrew_apps.sh
    exit_on_fail "Homebrew app install failed"

    list_appstore
}

main
