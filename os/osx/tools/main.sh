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



# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh"

    # run updates: skip osx
    ../../../bin/update 1
    exit_on_fail "Update failed"

    # xcode installed in init

    # TODO: check for install dependencies
    # install homebrew
    ./homebrew.sh
    exit_on_fail "Homebrew script failed"
    print_separator_large

    # install ruby (rbenv+packages)
    ./ruby.sh
    exit_on_fail "Ruby script failed"
    print_separator_large

    # install node (nvm+packages)
    ./node.sh
    exit_on_fail "Node script failed"
    print_separator_large

    # extra setup for tools
    ./extras.sh
    exit_on_fail "Extras script failed"
    print_separator_large

    # run updates: skip osx
    ../../../bin/update 1
    exit_on_fail "Update failed"

    # update shells
    if [[ -e "/usr/local/bin/bash" ]]; then
        sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
        # set shell to updated bash
        chsh -s '/usr/local/bin/bash'
    fi
    if [[ -e "/usr/local/bin/zsh" ]]; then
        sudo bash -c 'echo /usr/local/bin/zsh >> /etc/shells'
        # set shell to updated zsh (preferred over bash)
        chsh -s '/usr/local/bin/zsh'
    fi
}

main
