#!/usr/bin/env bash
#
# Set web preferences for chrome and safari

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

# set_preferences() {
#     #
# }

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh"

    print_info "Setting web preferences"
    set_preferences
    status_no_exit "Finished setting web preferences"
    printf "\n"
}

main
