#!/usr/bin/env bash
#
# Set some system preferences like dock settings and language

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

    print_info "Setting system preferences"
    set_preferences
    status_no_exit "Finished setting system preferences"
    printf "\n"
}

main
