#!/usr/bin/env bash
#
# Install server tools

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

#TODO: zsh-completions? pyenv? opam? fasd? samba?
#TODO: install rbenv oustide apt?

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

    # text boot
    # ./boot.sh
    # exit_on_fail "Boot script failed"
    # print_separator

    # install apt
    ./apt.sh
    exit_on_fail "APT script failed"
    print_separator

    # install ruby with rbenv
    # ./ruby.sh
    # exit_on_fail "Ruby script failed"
    # print_separator

    # install node with nvm
    # ./node.sh
    # exit_on_fail "Node script failed"
    # print_separator

    # install python with pyenv
    # ./python.sh
    # exit_on_fail "Node script failed"
    # print_separator

    local do_change_shell=1
    if [[ "$1" -eq 0 ]]; then
        do_change_shell=0
    else
        confirm "Use zsh?"
        do_change_shell="$?"
    fi
    # update shells
    if [[ do_change_shell -eq 0 ]]; then
        if [[ -e "/bin/zsh" ]]; then
            # set shell to updated zsh (preferred over bash)
            change_shell "/bin/zsh"
        elif [[ -e "/bin/bash" ]]; then
            # set shell to updated bash
            change_shell "/bin/bash"
        fi
    fi
}

main "$1"
