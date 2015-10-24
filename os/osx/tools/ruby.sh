#!/usr/bin/env bash
#
# Instally ruby through rbenv and some gems

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_BREW_FAILURE=101
declare -r E_RBENV_FAILURE=102
declare -r E_RUBY_INSTALL_FAILURE=103
declare -r E_GEM_NOT_FOUND=105

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

# rbenv
declare -r EXTRAS="${HOME}/dotfiles/shell/extra"
declare -r RBENV_DIRECTORY="${HOME}/.rbenv"
declare -r -a RUBY_VERSIONS=(
    "2.2.3"
)
declare -r CONFIGS='
# -----------------------------------------------------------------------------
# | rbenv                                                                      |
# -----------------------------------------------------------------------------

if which rbenv &> /dev/null; then
    rbenv init - &> /dev/null
fi
'

# gems
declare -r -a GEMS=(
    'tmuxinator'
)

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

install_rbenv() {
    # TODO: move to homebrew?
    if cmd_exists 'brew'; then
        # install
        brew install "rbenv" "ruby-build" > /dev/null
        status "rbenv+ruby-build installed" "${E_BREW_FAILURE}"
        if status_code; then
            printf "%s" "${CONFIGS}" >> "${EXTRAS}" \
                && source "${EXTRAS}"
            status_no_exit "rbenv (update ${EXTRAS})"
        fi

        # Install ruby versions
        for i in "${RUBY_VERSIONS[@]}"; do
            rbenv install "$i" > /dev/null
            status "rbenv (install: $i)" "${E_RBENV_FAILURE}"
        done
        if status_code; then
            rbenv global "${RUBY_VERSIONS[0]}" &> /dev/null
            status_no_exit "switched to ruby ${RUBY_VERSIONS[0]}"
        fi
    fi
}

# TODO: exit on fail
install_gems() {
    for i in "${GEMS[@]}"; do
        if [[ -n "$i"]]; then
            gem install "$i" &> /dev/null
            status_no_exit "ruby (gem): $i"
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

    if [[ ! -d "${RBENV_DIRECTORY}" ]]; then
        install_rbenv
        exit_on_fail "Install rbenv ruby"
    fi
    # Check if `gem` is installed
    if ! cmd_exists 'gem'; then
        errexit "ruby is required, please install it!\n" "${E_GEM_NOT_FOUND}"
    fi
    install_gems
}

main
