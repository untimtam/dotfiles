#!/usr/bin/env bash
#
# Instally ruby through rbenv and some gems

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_BREW_FAILURE=101
declare -r E_RBENV_FAILURE=102
declare -r E_RUBY_INSTALL_FAILURE=103
declare -r E_GEM_INSTALL_FAILURE=104
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
        start_spinner "Installing rbenv"
        brew install "rbenv" "ruby-build" >> "${ERROR_FILE}" 2>&1 > /dev/null
        status_stop_spinner "Finished installing rbenv"
        exit_on_fail "rbenv installation failed" "${E_BREW_FAILURE}"
        if status_code; then
            printf "%s" "${CONFIGS}" >> "${EXTRAS}" \
                && source "${EXTRAS}"
            status_no_exit "rbenv (update ${EXTRAS})"
        fi

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
            start_spinner "Installing $i"
            gem install "$i" &> /dev/null
            status_stop_spinner "Finished installing $i"
        fi
    done
    # TODO: exit on fail
    return 0
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
