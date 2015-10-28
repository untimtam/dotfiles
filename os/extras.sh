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

    git config --global user.name "${author}" >> "${ERROR_FILE}" 2>&1 > /dev/null \
        && git config --global user.email "${email}" >> "${ERROR_FILE}" 2>&1 > /dev/null \
        && git config --global credential.helper osxkeychain >> "${ERROR_FILE}" 2>&1 > /dev/null \
        && git config --global color.ui true >> "${ERROR_FILE}" 2>&1 > /dev/null \
        && git config --global core.excludesfile "${HOME}/.gitignore_global" >> "${ERROR_FILE}" 2>&1 > /dev/null
    status "Git config" "${E_GIT_CONFIG_FAILURE}"
}

# -----------------------------------------------------------------------------
# | Terminal                                                                   |
# -----------------------------------------------------------------------------

set_terminal() {
    osascript >> "${ERROR_FILE}" 2>&1 > /dev/null <<EOD

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
# | File extensions                                                            |
# -----------------------------------------------------------------------------

set_file_associations() {
    if cmd_exists 'duti'; then
        local -r DUTI_FILE="${HOME}/dotfiles/tools/duti/duti"
        duti "${DUTI_FILE}" >> "${ERROR_FILE}" 2>&1 > /dev/null
        status_no_exit "Set file associations according to ${DUTI_FILE}"
    fi
}

# -----------------------------------------------------------------------------
# | Custom Icons                                                               |
# | Using: Tina Latif's  http://flaticns.com/                                  |
# -----------------------------------------------------------------------------

# replace_icon(icns, app):
replace_icon() {
  file="$1"
  dest="$2"
  icon=/tmp/$(basename "${file}")
  rsrc=/tmp/icon.rsrc

  # generate rsrc
  cp "${file}" "${icon}"
  sips -i "${icon}" > /dev/null
  DeRez -only icns "${icon}" > "${rsrc}"

  # set icon
  Rez -append "${rsrc}" -o "$dest"$'/Icon\r'
  SetFile -a C "${dest}"
  SetFile -a V "$dest"$'/Icon\r'
}

# replace_app_icon(icns):
replace_app_icon() {
  icon="$1"
  name=$(basename "${icon}" .icns)
  app="/Applications/${name}.app"
  if [[ -d "${app}" ]]; then
    replace_icon "${icon}" "${app}"
    status_no_exit "Replaced ${name} icon"
  fi
}

# replace_icons(): replace app icons for installed apps (flat ui theme)
replace_icons() {
    local -r ICON_URL='https://github.com/tinalatif/flat.icns/archive/master.zip'
    local -r ICON_ZIP='/tmp/tinalatif-zip'
    local -r ICON_DIR='/tmp/tinalatif-icns'

    curl -LsS -o "${ICON_ZIP}" "${ICON_URL}" >> "${ERROR_FILE}" 2>&1 > /dev/null || return 1
    unzip -qq -o -j "${ICON_ZIP}" -d "${ICON_DIR}" >> "${ERROR_FILE}" 2>&1 > /dev/null || return 1

    # TODO: need sudo?
    print_info "Updating app icons"
    for file in ${ICON_DIR}/*.icns; do
      replace_app_icon "${file}"
    done
    print_success "Finished updating app icons"

    killall 'Dock'
    return 0
}

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../script/utils.sh"

    print_section "Extras stuff: "

    local extra=1
    if [[ "$1" -eq 0 ]]; then
        extra=0
        set_git_config
        exit_on_fail "Error setting up git config"
    else
        confirm "Install extras?"
        extra="$?"
        confirm "Set up git config?"
        if status_code; then
            set_git_config
            exit_on_fail "Error setting up git config"
        fi
    fi

    if [[ "${extra}" -eq 0 ]]; then
        local -r OS="$(get_os)"
        if [[ "${OS}" == "osx" ]]; then
            set_terminal
            exit_on_fail "Error setting up terminal app"

            set_iterm
            exit_on_fail "Error setting up iTerm"

            set_sublime
            exit_on_fail "Error setting up sublime"

            set_file_associations

            replace_icons
        elif [[ "${OS}" == "ununtu" ]]; then
            errexit "Ubuntu not supported yet!" "${E_INVALID_OS}"
        else
            errexit "This OS is not supported yet!" "${E_INVALID_OS}"
        fi
    fi

    print_success "Finished extra operations"
}

main "$1"
