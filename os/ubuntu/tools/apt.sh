#!/usr/bin/env bash
#
# Install apt tools

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_APT_FAILURE=101

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

declare -r -a APT=(
    'build-essential'

    'zsh'

    'git'
    'curl'
    'wget'
    'xclip'
    'tree'
    'tmux'

    'tar'
    'zip'
    'unzip'

    'exfat-utils'
    'exfat-fuse'

    'vim'

    # 'ssh-agent'
    'libssl-dev'
    'openssh-server'

    'transmission'
    'vlc'
)

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

install_apt_packages() {
    if cmd_exists 'apt-get'; then
        for i in "${APT[@]}"; do
            if [[ -n "$i" ]]; then
                start_spinner "Installing $i"
                install_package "$i" >> "${ERROR_FILE}" 2>&1 > /dev/null
                status_stop_spinner "Finished installing $i"
                exit_on_fail "$i installation failed" "${E_APT_FAILURE}"
            fi
        done
    fi
}

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh" \
        && source "../util.sh"

    update >> "${ERROR_FILE}" 2>&1 > /dev/null
    upgrade >> "${ERROR_FILE}" 2>&1 > /dev/null

    install_apt_packages
    exit_on_fail "APT package installations failed"

    update >> "${ERROR_FILE}" 2>&1 > /dev/null
    upgrade >> "${ERROR_FILE}" 2>&1 > /dev/null
    autoremove >> "${ERROR_FILE}" 2>&1 > /dev/null
}

main "$1"
