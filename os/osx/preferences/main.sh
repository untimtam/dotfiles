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
    "SystemUIServer"
    "cfprefsd"
)

# declare -a APPS=(
#     "SystemUIServer"
#     "cfprefsd"
#     "Activity Monitor"
#     "Address Book"
#     "Calendar"
#     "Contacts"
#     "Dock"
#     "Finder"
#     "Google Chrome"
#     "Google Chrome Canary"
#     "Mail"
#     "Messages"
#     "Safari"
#     "Spectacle"
#     "Transmission"
# )

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

    # general prefs
    ./general.sh
    # system prefs
    ./system.sh
    # web prefs
    ./web.sh
    # apple prefs
    ./apple.sh
    # terminal prefs
    ./terminal.sh
    # app prefs
    ./apps.sh

    # for app in ${APPS[*]}; do
    #     killall "${app}" &> /dev/null
    # done
}

main
