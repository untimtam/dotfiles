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

    # run updates: skip osx
    ../../../bin/update gem pip
    exit_on_fail "Update failed"
    print_separator

    # xcode installed in init

    # TODO: check for install dependencies
    # install homebrew
    ./homebrew.sh
    exit_on_fail "Homebrew script failed"
    print_separator

    # install ruby (rbenv+packages)
    ./ruby.sh
    exit_on_fail "Ruby script failed"
    print_separator

    # install node (nvm+packages)
    ./node.sh
    exit_on_fail "Node script failed"
    print_separator

    # extra setup for tools
    # ./extras.sh
    # exit_on_fail "Extras script failed"
    # print_separator

    # run updates: skip osx
    ../../../bin/update brew npm gem pip pip3
    exit_on_fail "Update failed"

    # update shells
    if [[ -e "/usr/local/bin/bash" ]]; then
        sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
        # set shell to updated bash
        change_shell "/usr/local/bin/bash"
    fi
    if [[ -e "/usr/local/bin/zsh" ]]; then
        sudo bash -c 'echo /usr/local/bin/zsh >> /etc/shells'
        # set shell to updated zsh (preferred over bash)
        change_shell "/usr/local/bin/zsh"
    fi
}

main
