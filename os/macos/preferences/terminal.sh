#!/usr/bin/env bash
#
# Set terminal preferences

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_PREFERENCE_FAILURE=101

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

# cant close terminals because they could be running this script
declare -r -a APPS=(
    ''
)

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

terminal_preferences() {
    # Only use UTF-8 in Terminal.app
    defaults write com.apple.terminal StringEncodings -array 4

    # Enable “focus follows mouse” for Terminal.app and all X11 apps
    # i.e. hover over a window and start typing in it without clicking first
    # defaults write com.apple.terminal FocusFollowsMouse -bool true
    # defaults write org.x.X11 wm_ffm -bool true

    # Enable Secure Keyboard Entry in Terminal.app
    # See: https://security.stackexchange.com/a/47786/8918
    defaults write com.apple.terminal SecureKeyboardEntry -bool true

    # Disable the annoying line marks
    defaults write com.apple.Terminal ShowLineMarks -int 0
}

iterm_preferences() {
    # Don’t display the annoying prompt when quitting iTerm
    defaults write com.googlecode.iterm2 PromptOnQuit -bool false
}

set_preferences() {
    start_spinner "Setting Terminal preferences"
    terminal_preferences >> "${ERROR_FILE}" 2>&1 > /dev/null
    status_stop_spinner "Finished setting Terminal preferences"
    exit_on_fail "Terminal preferences failed" "${E_PREFERENCE_FAILURE}"

    start_spinner "Setting iTerm preferences"
    iterm_preferences >> "${ERROR_FILE}" 2>&1 > /dev/null
    status_stop_spinner "Finished setting iTerm preferences"
    exit_on_fail "iTerm preferences failed" "${E_PREFERENCE_FAILURE}"
}

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh"

    print_info "Setting terminal preferences"
    set_preferences
    status_no_exit "Finished setting terminal preferences"

    for app in "${APPS[@]}"; do
        if [[ -n "${app}" ]]; then
            killall "${app}" &> /dev/null
        fi
    done
    return 0
}

main
