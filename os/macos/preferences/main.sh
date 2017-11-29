#!/usr/bin/env bash
#
# Set all osx preferences

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

declare -a APPS=(
    'SystemUIServer'
    'cfprefsd'
)

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh"

    # Close any open System Preferences panes, to prevent them from overriding
    # settings we’re about to change
    osascript -e 'tell application "System Preferences" to quit'

    # TODO: break up large preferences into smaller chunks internally
    # general prefs
    ./general.sh
    exit_on_fail "General Preferences failed"
    print_separator
    # system prefs
    ./system.sh "$1"
    exit_on_fail "System Preferences failed"
    print_separator
    # web prefs
    ./web.sh
    exit_on_fail "Web Preferences failed"
    print_separator
    # apple prefs
    ./apple.sh
    exit_on_fail "Apple Preferences failed"
    print_separator
    # terminal prefs
    ./terminal.sh
    exit_on_fail "Terminal Preferences failed"
    print_separator
    # app prefs
    ./apps.sh
    exit_on_fail "App Preferences failed"
    print_separator

    for app in "${APPS[@]}"; do
        if [[ -n "${app}" ]]; then
            killall "${app}" &> /dev/null
        fi
    done

    return 0
}

main "$1"
