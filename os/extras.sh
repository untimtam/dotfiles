#!/usr/bin/env bash
#
# Perform any extra operations
#
# Setup github config
# Set theme in Terminal and iTerm2
# Set sublime preferences
# Install some basic packages

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

# git config
declare -r E_GIT_CONFIG_FAILURE=101

# iTerm app
declare -r E_CLOSE_ITERM_FAILURE=102
declare -r E_COPY_PREFERENCE_FAILURE=103
declare -r E_READ_PREFERENCE_FAILURE=104

# sublime app
declare -r E_COPY_SETTING_FAILURE=105
declare -r E_DL_PACKAGE_CONTROL_FAILURE=106
declare -r E_PACKAGES_FAILURE=107

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Git                                                                        |
# -----------------------------------------------------------------------------

set_git_config() {
    local author=""
    local email=""

    # Git author name
    question_prompt "Git author name?"
    author="${REPLY}"
    # Git author email
    question_prompt "Git author email?"
    email="${REPLY}"

    git config --global user.name "${author}" >> "${ERROR_FILE}" 2>&1 > /dev/null \
        && git config --global user.email "${email}" >> "${ERROR_FILE}" 2>&1 > /dev/null \
        && git config --global credential.helper osxkeychain >> "${ERROR_FILE}" 2>&1 > /dev/null \
        && git config --global color.ui true >> "${ERROR_FILE}" 2>&1 > /dev/null \
        && git config --global core.excludesfile "${HOME}/.gitignore_global" >> "${ERROR_FILE}" 2>&1 > /dev/null
    status "Git config" "${E_GIT_CONFIG_FAILURE}"
}

# -----------------------------------------------------------------------------
# | Iterm                                                                      |
# -----------------------------------------------------------------------------

set_iterm() {
    if [[ -e "/Applications/iTerm.app" ]]; then
        print_info "Opening iTerm"
        open -a "iTerm" >> "${ERROR_FILE}" 2>&1 > /dev/null
        status_no_exit "Finished opening iTerm"
        sleep 5
        # close iterm
        print_info "Closing iTerm"
        killall "iTerm" >> "${ERROR_FILE}" 2>&1 > /dev/null
        status "Finished closing iterm" "${E_CLOSE_ITERM_FAILURE}"

        # copy preferences
        cp -R "${HOME}/dotfiles/resources/com.googlecode.iterm2.plist" \
            "${HOME}/Library/Preferences/com.googlecode.iterm2.plist" >> "${ERROR_FILE}" 2>&1 > /dev/null
        status "copy iterm preferences" "${E_COPY_PREFERENCE_FAILURE}"
        # read preferences
        defaults read com.googlecode.iterm2 >> "${ERROR_FILE}" 2>&1 > /dev/null
        status "read iterm preferences" "${E_READ_PREFERENCE_FAILURE}"
    fi
}

# -----------------------------------------------------------------------------
# | Sublime                                                                    |
# -----------------------------------------------------------------------------

set_sublime() {
    if [[ -e "/Applications/Sublime Text.app" ]]; then
        print_info "Opening Sublime Text"
        open -a "Sublime Text" >> "${ERROR_FILE}" 2>&1 > /dev/null
        status_no_exit "Finished opening Sublime Text"
        sleep 5
        # close iterm
        print_info "Closing Sublime Text"
        killall "Sublime Text" >> "${ERROR_FILE}" 2>&1 > /dev/null
        status "Finished closing Sublime Text" "${E_CLOSE_ITERM_FAILURE}"

        local st3="${HOME}/Library/Application Support/Sublime Text 3"
        local name="Package Control"
        # sublime settings
        cp -R "${HOME}/dotfiles/resources/Preferences.sublime-settings" "${st3}/Packages/User/Preferences.sublime-settings" >> "${ERROR_FILE}" 2>&1 > /dev/null
        status "Copy sublime preferences" "${E_COPY_SETTING_FAILURE}"
        # install package control
        curl -LsS -o "${st3}/Installed Packages/${name}.sublime-package" "https://packagecontrol.io/Package%20Control.sublime-package" >> "${ERROR_FILE}" 2>&1 > /dev/null
        status "Download package control" "${E_DL_PACKAGE_CONTROL_FAILURE}"
        # install packages
        cp -R "${HOME}/dotfiles/resources/${name}.sublime-settings" "${st3}/Packages/User/${name}.sublime-settings" >> "${ERROR_FILE}" 2>&1 > /dev/null
        status "write package control settings" "${E_PACKAGES_FAILURE}"
    fi
}

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../script/utils.sh"

    print_section "Extras: "

    # TODO: check os and then do os x specific things in a funciton?

    set_git_config
    exit_on_fail "Error setting up git config"

    set_iterm
    exit_on_fail "Error setting up iTerm"

    set_sublime
    exit_on_fail "Error setting up sublime"

    print_success "Finished extra operations"
}

main "$1"
