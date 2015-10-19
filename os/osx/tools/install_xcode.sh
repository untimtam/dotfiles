#!/usr/bin/env bash
#
# Install xcode command line tools

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_INSTALL_FAILED=101
declare -r E_XCODE_INSTALL_FAILED=102

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh"

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

        # prompt user to agree to xcode terms
        # https://github.com/alrra/dotfiles/issues/10
        sudo xcodebuild -license &> /dev/null
        status_no_exit "Agree with the XCode Command Line Tools licence"
    fi

    print_success "Xcode command line tools"
}

main
