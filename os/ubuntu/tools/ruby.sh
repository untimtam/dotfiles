#!/usr/bin/env bash
#
#

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_CLONE_FAILURE=101
declare -r E_RBENV_FAILURE=102
declare -r E_GEM_INSTALL_FAILURE=103
declare -r E_RBENV_REHASH_FAILURE=104
declare -r E_GEM_NOT_FOUND=105

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

# TODO: share install with osx (most of the code is the same)
declare -r RBENV_DIRECTORY="${HOME}/.rbenv"

declare -r -a RUBY_VERSIONS=(
    '2.3.0'
    '2.2.3'
)

# gems
declare -r -a GEMS=()

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

clone_rbenv() {
    start_spinner "Installing rbenv"
    git clone https://github.com/rbenv/rbenv.git "${RBENV_DIRECTORY}"
    status_stop_spinner "Finished installing rbenv"
    exit_on_fail "rbenv installation failed" "${E_CLONE_FAILURE}"
}

clone_ruby_build() {
    start_spinner "Installing ruby-build"
    git clone https://github.com/rbenv/ruby-build.git "${RBENV_DIRECTORY}/plugins/ruby-build"
    status_stop_spinner "Finished installing ruby-build"
    exit_on_fail "ruby-build installation failed" "${E_CLONE_FAILURE}"
}

clone_ruby_rehash() {
    start_spinner "Installing rbenv-gem-rehash"
    git clone https://github.com/rbenv/rbenv-gem-rehash.git "${RBENV_DIRECTORY}/plugins/rbenv-gem-rehash"
    status_stop_spinner "Finished installing rbenv-gem-rehash"
    exit_on_fail "rbenv-gem-rehash installation failed" "${E_CLONE_FAILURE}"
}

install_rbenv() {
    clone_rbenv
    exit_on_fail "Could not install rbenv"

    # exec "${SHELL}" -l

    # rbenv init
    ${RBENV_DIRECTORY}/bin/rbenv init - &> /dev/null
    status "Initializing rbenv" "${E_RBENV_FAILURE}"

    clone_ruby_build
    exit_on_fail "Could not install ruby-build"

    clone_ruby_rehash
    exit_on_fail "Could not install rbenv-gem-rehash"

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

main "$1"
