#!/usr/bin/env bash
#
# Instally ruby through rbenv and some gems

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_BREW_FAILURE=101
declare -r E_RBENV_FAILURE=102
declare -r E_GEM_INSTALL_FAILURE=103
declare -r E_RBENV_REHASH_FAILURE=104
declare -r E_GEM_NOT_FOUND=105

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

# rbenv
declare -r RBENV_DIRECTORY="${HOME}/.rbenv"
declare -r -a RUBY_VERSIONS=(
    '2.2.3'
    '2.3.1'
)

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
        start_spinner "Installing rbenv"
        brew install "rbenv" "ruby-build" >> "${ERROR_FILE}" 2>&1 > /dev/null
        status_stop_spinner "Finished installing rbenv"
        exit_on_fail "rbenv installation failed" "${E_BREW_FAILURE}"

        # rbenv init
        rbenv init - &> /dev/null
        status "Initializing rbenv" "${E_RBENV_FAILURE}"

        # Install ruby versionsg
        for i in "${RUBY_VERSIONS[@]}"; do
            start_spinner "Installing ruby $i"
            rbenv install "$i" >> "${ERROR_FILE}" 2>&1 > /dev/null
            status_stop_spinner "Finished installing ruby $i"
            exit_on_fail "ruby $i installation failed" "${E_RBENV_FAILURE}"
        done
        if status_code; then
            rbenv global "${RUBY_VERSIONS[0]}" &> /dev/null
            status_no_exit "switched to ruby ${RUBY_VERSIONS[0]}"
        fi
    fi
}

install_gems() {
    for i in "${GEMS[@]}"; do
        if [[ -n "$i" ]]; then
            # TODO: detect gems that are already installed
            start_spinner "Installing $i"
            ${HOME}/.rbenv/shims/gem install "$i" &> /dev/null
            status_stop_spinner "Finished installing $i"
            exit_on_fail "rbenv gem installation failed" "${E_GEM_INSTALL_FAILURE}"
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

    # Check if rbenv `gem` is installed at this point
    if ! cmd_exists "${HOME}/.rbenv/shims/gem" ; then
        errexit "ruby is required, please install it!\n" "${E_GEM_NOT_FOUND}"
    fi
    install_gems
    rbenv rehash
    status "Rehash rbenv shims" "${E_RBENV_REHASH_FAILURE}"
}

main
