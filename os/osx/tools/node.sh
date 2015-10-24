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

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

# NVM
declare -r EXTRAS="${HOME}/dotfiles/shell/extra"
declare -r NVM_DIRECTORY="${HOME}/.nvm"
declare -r -a NODE_VERSIONS=(
    "node"
)
declare -r CONFIGS='
# -----------------------------------------------------------------------------
# | NVM                                                                        |
# -----------------------------------------------------------------------------

export NVM_DIR="'${NVM_DIRECTORY}'"
[[ -f "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh"
'

# NPM
declare -r -a NPM_PACKAGES=(
    'npm-check'

    'gulp'
    'grunt-cli'

    'bower'

    'stylus'
    'jade'
    'coffee-script'

    'jscs'
    'jsonlint'
    'coffeelint'

    'nodemon'
    'browser-sync'
    'express-generator'

    'yo'

    'resume-cli'

    'vmd'

    'vulcanize'
    'generator-polymer'
    'web-component-tester'
)

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

install_nvm() {
    git clone https://github.com/creationix/nvm.git "${NVM_DIRECTORY}" &> /dev/null
    status "nvm cloned" "${E_NVM_CLONE_FAILURE}"
    if status_code; then
        # nvm.sh should work in both bash and zsh
        printf "%s" "${CONFIGS}" >> "${EXTRAS}" \
            && source "${EXTRAS}"
        status_no_exit "nvm (update ${EXTRAS})"
    fi
}

update_nvm() {
    # Ensure the latest version of `nvm` is used
    cd "${NVM_DIRECTORY}" && git checkout `git describe --abbrev=0 --tags` &> /dev/null
    status "nvm (update)" "${E_NVM_UPDATE_FAILURE}"

    source "${NVM_DIRECTORY}/nvm.sh"

    # Install node versions
    for i in "${NODE_VERSIONS[@]}"; do
        nvm install "$i" >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
        status "nvm (install: $i)" "${E_NVM_NODE_FAILURE}"
    done

    # Use `Node.js` by default
    nvm alias default node >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
    status_no_exit "nvm (set default)"
}

update_npm() {
    npm install -g npm >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
    status "npm (update)" "${E_NODE_NPM_FAILURE}"
}

install_npm_packages() {
    # Install the `npm` packages
    for i in "${NPM_PACKAGES[@]}"; do
        if [[ -n "$i"]]; then
            npm install -g "$i" >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
            status_no_exit "npm (package): $i"
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

    # Install `nvm` and add the necessary configs to `~/dotfiles/shell/extra`
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
    [[ -z "${NVM_DIR}" ]] && source "${EXTRAS}"
    # Check if `npm` is installed
    if ! cmd_exists 'npm'; then
        errexit "npm is required, please install it!\n" "${E_NPM_NOT_FOUND}"
    fi
    update_npm
    install_npm_packages
}

main
