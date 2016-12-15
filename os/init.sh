#!/usr/bin/env bash
#
# OS Specific initialization for fresh install

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_OSX_UPDATE_FAILURE=101
declare -r E_INVALID_OS=102
declare -r E_TOOL_INSTALL_FAILED=103

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

osx_init() {
    if ! xcode-select -p &> /dev/null; then
        print_info "Installing XCode command line tools"

        # prompt user to install command line tools
        xcode-select --install &> /dev/null
        # wait for installation to be complete
        while ! xcode-select -p &> /dev/null; do
            sleep 5
        done

        status "Command line tools" "${E_TOOL_INSTALL_FAILED}"

        # point xcode-select developer directory to appropriate directory
        # https://github.com/alrra/dotfiles/issues/13
        sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer &> /dev/null
        status_no_exit 'Make "xcode-select" developer directory point to Xcode'
        # TODO: switch to another location?

        # prompt user to agree to xcode terms
        # https://github.com/alrra/dotfiles/issues/10
        sudo xcodebuild -license &> /dev/null
        status_no_exit "Agree with the XCode Command Line Tools licence"

        print_success "Finished installing pre-req tools"
    fi
}

ubuntu_init() {
    request_sudo

    sudo apt-get install git xclip
    status "Command line tools" "${E_TOOL_INSTALL_FAILED}"

    print_success "Finished installing pre-req tools"
}

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../script/utils.sh"

    print_section "Running initialization"

    # update os
    ../bin/update os

    local -r OS="$(get_os)"
    if [[ "${OS}" == "osx" ]]; then
        # install xcode command line tools
        osx_init
        exit_on_fail "OSX init failed"
    elif [[ "${OS}" == "ubuntu" ]]; then
        # install pre-req tools
        ubuntu_init
    else
        errexit "This OS is not supported yet!" "${E_INVALID_OS}"
    fi

    print_success "Finished running initialization"
}

main "$1"
