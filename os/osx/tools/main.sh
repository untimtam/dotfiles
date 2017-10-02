#!/usr/bin/env bash
#
# Install all relevant tools

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

change_shell() {
    chsh -s "$1"
    if ! status_code; then
        confirm "Try changing shell again?"
        if status_code; then
            change_shell "$1"
        fi
    fi
}

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh"

    # xcode already installed in init

    # TODO: check for install dependencies
    # install homebrew
    ./homebrew.sh
    exit_on_fail "Homebrew script failed"
    print_separator

    local do_change_shell=1
    if [[ "$1" -eq 0 ]]; then
        do_change_shell=0
    else
        confirm "Install tools?"
        do_change_shell="$?"
    fi
    # update shells
    if [[ do_change_shell -eq 0 ]]; then
        # TODO: should only run once now but make sure we dont polute /etc/shells?
        sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
        sudo bash -c 'echo /usr/local/bin/zsh >> /etc/shells'
        if [[ -e "/usr/local/bin/zsh" ]]; then
            # set shell to updated zsh (preferred over bash)
            change_shell "/usr/local/bin/zsh"
        elif [[ -e "/usr/local/bin/bash" ]]; then
            # set shell to updated bash
            change_shell "/usr/local/bin/bash"
        fi
    fi
}

main "$1"
