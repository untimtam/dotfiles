#!/usr/bin/env bash
#
# OS Specific initialization for fresh install

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_INVALID_OS=101
declare -r E_OSX_UPDATE_FAILURE=102
declare -r E_XCODE_INSTALL_FAILED=103

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

install_xcode(){
    if ! xcode-select -p &> /dev/null; then
        print_info "Installing XCode command line tools"

        # prompt user to install command line tools
        xcode-select --install &> /dev/null
        # wait for installation to be complete
        while ! xcode-select -p &> /dev/null; do
            sleep 5
        done

        status "Command line tools" "${E_XCODE_INSTALL_FAILED}"

        # point xcode-select developer directory to appropriate directory
        # https://github.com/alrra/dotfiles/issues/13
        sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer &> /dev/null
        status_no_exit 'Make "xcode-select" developer directory point to Xcode'
        # TODO: switch to another location?

        # prompt user to agree to xcode terms
        # https://github.com/alrra/dotfiles/issues/10
        sudo xcodebuild -license &> /dev/null
        status_no_exit "Agree with the XCode Command Line Tools licence"

        print_success "Finished installing XCode tools"
    fi
}

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../script/utils.sh"

    print_section "Running initialization"

    local -r OS="$(get_os)"
    if [[ "${OS}" == "osx" ]]; then
        # update osx
        print_info "If OSX update requires restart, please run 'cd ${HOME} && ./dotfiles/script/bootstrap'"
        sudo softwareupdate -ia > /dev/null
        status "updated osx" "${E_OSX_UPDATE_FAILURE}"
        # install xcode command line tools
        install_xcode
        exit_on_fail "Xcode install failed"
    elif [[ "${OS}" == "ununtu" ]]; then
        errexit "Ubuntu not supported yet!" "${E_INVALID_OS}"
    else
        errexit "This OS is not supported yet!" "${E_INVALID_OS}"
    fi

    print_success "Finished running initialization"
}

main "$1"
