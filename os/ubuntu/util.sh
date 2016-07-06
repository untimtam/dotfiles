#!/usr/bin/env bash
#
# Utilities for application installation

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

if [[ -z "${ERROR_FILE}" ]]; then
    # only declare if main utils not sourced
    declare -r ERROR_FILE="${HOME}/dotfiles/dot_error.log"
fi

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

update() {
    sudo apt-get update -qqy >> "${ERROR_FILE}" 2>&1 > /dev/null
}

upgrade() {
    sudo apt-get upgrade -qqy >> "${ERROR_FILE}" 2>&1 > /dev/null
}

autoremove() {
    sudo apt-get autoremove -qqy >> "${ERROR_FILE}" 2>&1 > /dev/null
}

add_key() {
    wget -qO - "$1" | sudo apt-key add - &> /dev/null
    #     │└─ write output to file
    #     └─ don't show output
}

add_ppa() {
    sudo add-apt-repository -y ppa:"$1" &> /dev/null
}

add_to_source_list() {
    sudo sh -c "printf 'deb $1' >> '/etc/apt/sources.list.d/$2'"
}

package_is_installed() {
    dpkg -s "$1" &> /dev/null
}

install_package() {
    if package_is_installed "$1"; then
        print_success "$i is already installed"
        return 0
    else
        sudo apt-get install --allow-unauthenticated -qqy "$1" >> "${ERROR_FILE}" 2>&1 > /dev/null
        #                             suppress output ─┘│
        #   assume "yes" as the answer to all prompts ──┘
        return "$?"
    fi
}
