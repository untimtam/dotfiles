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

# terminal app
declare -r E_TERMINAL_THEME_FAILURE=102

# iTerm app
declare -r E_CLOSE_ITERM_FAILURE=103
declare -r E_COPY_PREFERENCE_FAILURE=104
declare -r E_READ_PREFERENCE_FAILURE=105

# sublime app
declare -r E_COPY_SETTING_FAILURE=106
declare -r E_DL_PACKAGE_CONTROL_FAILURE=107
declare -r E_PACKAGES_FAILURE=108

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

    git config --global user.name "${author}" \
        && git config --global user.email "${email}" \
        && git config --global credential.helper osxkeychain \
        && git config --global color.ui true
    status "Git config" "${E_GIT_CONFIG_FAILURE}"
}

# -----------------------------------------------------------------------------
# | Terminal                                                                   |
# -----------------------------------------------------------------------------

set_terminal() {
    osascript &> /dev/null <<EOD

tell application "Terminal"

    local allOpenedWindows
    local initialOpenedWindows
    local windowID
    set themeName to "Hellowor1d"

    (* Store the IDs of all the open terminal windows. *)
    set initialOpenedWindows to id of every window

    (* Open the custom theme so that it gets added to the list
       of available terminal themes (note: this will open two
       additional terminal windows). *)
    do shell script "open '$HOME/dotfiles/resources/" & themeName & ".terminal'"

    (* Wait a little bit to ensure that the custom theme is added. *)
    delay 1

    (* Set the custom theme as the default terminal theme. *)
    set default settings to settings set themeName

    (* Get the IDs of all the currently opened terminal windows. *)
    set allOpenedWindows to id of every window

    repeat with windowID in allOpenedWindows

        (* Close the additional windows that were opened in order
           to add the custom theme to the list of terminal themes. *)
        if initialOpenedWindows does not contain windowID then
            close (every window whose id is windowID)

        (* Change the theme for the initial opened terminal windows
           to remove the need to close them in order for the custom
           theme to be applied. *)
        else
            set current settings of tabs of (every window whose id is windowID) to settings set themeName
        end if

    end repeat

end tell

EOD
    status "Set terminal.app theme" "${E_TERMINAL_THEME_FAILURE}"
}

# -----------------------------------------------------------------------------
# | Iterm                                                                      |
# -----------------------------------------------------------------------------

set_iterm() {
    # close iterm
    killall "iTerm" &> /dev/null
    status "close iterm" "${E_CLOSE_ITERM_FAILURE}"
    # copy preferences
    cp -r "${HOME}/dotfiles/resources/com.googlecode.iterm2.plist" "${HOME}/Library/Preferences/com.googlecode.iterm2.plist" &> /dev/null
    status "copy iterm preferences" "${E_COPY_PREFERENCE_FAILURE}"
    # read preferences
    defaults read com.googlecode.iterm2 &> /dev/null
    status "read iterm preferences" "${E_READ_PREFERENCE_FAILURE}"
}

# -----------------------------------------------------------------------------
# | Sublime                                                                    |
# -----------------------------------------------------------------------------

set_sublime() {
    local st3="${HOME}/Library/Application\ Support/Sublime\ Text\ 3"
    local name="Package\ Control"
    # sublime settings
    cp -r "${HOME}/dotfiles/resources/Preferences.sublime-settings" "${st3}/Packages/User/Preferences.sublime-settings" &> /dev/null
    status "Copy sublime preferences" "${E_COPY_SETTING_FAILURE}"
    # install package control
    curl -LsSo "${st3}/Installed\ Packages/${name}.sublime-package" "https://packagecontrol.io/Package%20Control.sublime-package" &> /dev/null
    status "Download package control" "${E_DL_PACKAGE_CONTROL_FAILURE}"
    # install packages
    cp -r "${HOME}/dotfiles/resources/${name}.sublime-settings" "${st3}/Packages/User/${name}.sublime-settings" &> /dev/null
    status "write package control settings" "${E_PACKAGES_FAILURE}"
}

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../script/utils.sh"

    print_section "Extras: "

    set_git_config
    exit_on_fail "Error setting up git config"

    set_terminal
    exit_on_fail "Error setting up terminal app"

    set_iterm
    exit_on_fail "Error setting up iTerm"

    set_sublime
    exit_on_fail "Error setting up sublime"

    print_success "Finished extra operations"
}

main "$1"
