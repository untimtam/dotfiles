#!/usr/bin/env bash
#
# Install node through nvm and some packages

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_GIT_NOT_FOUND=101
declare -r E_NPM_NOT_FOUND=102
declare -r E_NVM_CLONE_FAILURE=103
declare -r E_NVM_UPDATE_FAILURE=104
declare -r E_NVM_NODE_FAILURE=105
declare -r E_NODE_NPM_FAILURE=106
declare -r E_NPM_INSTALL_FAILURE=107

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

# NVM
declare -r NVM_DIRECTORY="${HOME}/.nvm"
declare -r -a NODE_VERSIONS=(
    "node"
)

# NPM
declare -r -a NPM_PACKAGES=(
    'npm-check'

    'gulp'

    'bower'

    'stylus'
    'pug'
    'coffee-script'

    'jscs'
    'jsonlint'

    'nodemon'
    'browser-sync'

    'vmd'
    'tldr'

    'termcolors'
)

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

install_nvm() {
    start_spinner "Installing nvm"
    git clone https://github.com/creationix/nvm.git "${NVM_DIRECTORY}" &> /dev/null
    status_stop_spinner "Finished installing nvm"
    exit_on_fail "nvm installation failed" "${E_NVM_CLONE_FAILURE}"
}

update_nvm() {
    # Ensure the latest version of `nvm` is used
    start_spinner "Updating nvm"
    cd "${NVM_DIRECTORY}" && git checkout `git describe --abbrev=0 --tags` &> /dev/null
    status_stop_spinner "Finished updating nvm"
    exit_on_fail "nvm update failed" "${E_NVM_UPDATE_FAILURE}"

    source "${NVM_DIRECTORY}/nvm.sh"

    # Install node versions
    for i in "${NODE_VERSIONS[@]}"; do
        start_spinner "Installing node"
        nvm install "$i" >> "${ERROR_FILE}" 2>&1 > /dev/null
        status_stop_spinner "Finished installing node"
        exit_on_fail "nvm installation failed" "${E_NVM_NODE_FAILURE}"
    done

    # Use `Node.js` by default
    nvm alias default node >> "${ERROR_FILE}" 2>&1 > /dev/null
    status_no_exit "nvm (set default)"
}

update_npm() {
    start_spinner "Updating npm"
    npm install -g npm >> "${ERROR_FILE}" 2>&1 > /dev/null
    status_stop_spinner "Finished updating npm"
    exit_on_fail "npm update failed" "${E_NODE_NPM_FAILURE}"
}

install_npm_packages() {
    # Install the `npm` packages
    for i in "${NPM_PACKAGES[@]}"; do
        if [[ -n "$i" ]]; then
            # TODO: is there a better way of detecting installed package?
            if npm -g list "$i" &> /dev/null; then
                print_success "$i is already installed"
            else
                start_spinner "Installing $i"
                npm -g install "$i" >> "${ERROR_FILE}" 2>&1 > /dev/null
                status_stop_spinner "Finished installing $i"
                exit_on_fail "$i installation failed" "${E_NPM_INSTALL_FAILURE}"
            fi
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

    # Check if `Git` is installed
    if ! cmd_exists 'git'; then
        errexit "Git is required, please install it!\n" "${E_GIT_NOT_FOUND}"
    fi

    # Install `nvm`
    if [[ ! -d "${NVM_DIRECTORY}" ]]; then
        install_nvm
        exit_on_fail "NVM install failed"
    fi

    # update nvm either regularly or after installation
    if [[ -d "${NVM_DIRECTORY}" ]]; then
        update_nvm
        exit_on_fail "NVM update failed"
    fi

    # Update NPM
    [[ -z "${NVM_DIR}" ]] && source "${HOME}/dotfiles/shell/extra"
    # Check if `npm` is installed
    if ! cmd_exists 'npm'; then
        errexit "npm is required, please install it!\n" "${E_NPM_NOT_FOUND}"
    fi
    update_npm
    install_npm_packages
}

main
