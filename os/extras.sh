#!/usr/bin/env bash
#
# Perform any extra operations

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

set_git_config() {
    local author=""
    local email=""

    # Git author name
    question_prompt "Git author name?"
    author="${REPLY}"
    # Git author email
    question_prompt "Git author email?"
    email="${REPLY}"

    git config --global user.name "${author}"
    git config --global user.email "${email}"
}

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../script/utils.sh"

    print_section "Extras: "

    set_git_config
    status_no_exit "Set up git config"

    print_success "Finished extra operations"
}

main "$1"
