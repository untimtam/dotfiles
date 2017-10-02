#!/usr/bin/env bash
#
# Set general preferences for UI and UX

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_PREFERENCE_FAILURE=101

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

declare -r -a APPS=(
    ''
)
declare COMPUTER_NAME="foo"
declare HD_NAME="box"

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

set_computer_name() {
    confirm "Set computer name to ${COMPUTER_NAME}"
    if ! status_code; then
        question_prompt "What would you like instead?"
        COMPUTER_NAME="${REPLY}"
    fi
}

set_hd_name() {
    confirm "Set primary hard drive name to ${HD_NAME}"
    if ! status_code; then
        question_prompt "What would you like instead?"
        HD_NAME="${REPLY}"
    fi
}

general_preferences() {
    # Set computer name (as done via System Preferences → Sharing)
    # ex: Jarvis, Mark I, box, abacus, scud
    sudo scutil --set ComputerName "${COMPUTER_NAME}"
    sudo scutil --set HostName "${COMPUTER_NAME}"
    sudo scutil --set LocalHostName "${COMPUTER_NAME}"
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${COMPUTER_NAME}"

    # Set harddrive name
    diskutil rename / "${HD_NAME}"

    # Set standby delay to 24 hours (default is 1 hour)
    sudo pmset -a standbydelay 86400

    # Disable the sound effects on boot
    sudo nvram SystemAudioVolume=" "

    # Menu bar: hide the User icon
    for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
        defaults write "${domain}" dontAutoLoad -array "/System/Library/CoreServices/Menu Extras/User.menu"
    done
    defaults write com.apple.systemuiserver menuExtras -array \
        "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
        "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
        "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
        "/System/Library/CoreServices/Menu Extras/Battery.menu" \
        "/System/Library/CoreServices/Menu Extras/Volume.menu" \
        "/System/Library/CoreServices/Menu Extras/Clock.menu"

    # hide remaining battery time, show percentage.
    defaults write com.apple.menuextra.battery ShowPercent -string "YES"
    defaults write com.apple.menuextra.battery ShowTime -string "NO"

    # Set highlight color
    # Aqua
    defaults write NSGlobalDomain AppleHighlightColor -string "0.000000 0.673776 0.999931"
    # Green "0.764700 0.976500 0.568600"
    # Graphite "0.780400 0.815700 0.858800"

    # Always show scrollbars
    # Possible values: `WhenScrolling`, `Automatic` and `Always`
    defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

    # Increase window resize speed for Cocoa applications
    defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

    # Save to disk (not to iCloud) by default
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    # Automatically quit printer app once the print jobs complete
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

    # Disable the “Are you sure you want to open this application?” dialog
    defaults write com.apple.LaunchServices LSQuarantine -bool false

    # Remove duplicates in the “Open With” menu (also see `lscleanup` alias)
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

    # Display ASCII control characters using caret notation in standard text views
    # Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
    defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

    # Disable Resume system-wide
    defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

    # Disable automatic termination of inactive apps
    defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

    # Set Help Viewer windows to non-floating mode
    defaults write com.apple.helpviewer DevMode -bool true

    # Reveal IP address, hostname, OS version, etc. when clicking the clock
    # in the login window
    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

    # Restart automatically if the computer freezes
    sudo systemsetup -setrestartfreeze on

    # Never go into computer sleep mode
    sudo systemsetup -setcomputersleep Off >> "${ERROR_FILE}" 2>&1 > /dev/null

    # Disable smart quotes
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

    # Disable smart dashes
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
}

ssd_preferences() {
    # Disable local Time Machine snapshots
    sudo tmutil disablelocal

    # Disable hibernation (speeds up entering sleep mode)
    sudo pmset -a hibernatemode 0

    # Disable the sudden motion sensor as it’s not useful for SSDs
    sudo pmset -a sms 0
}

set_preferences() {
    set_computer_name
    set_hd_name
    start_spinner "Setting basic preferences"
    general_preferences >> "${ERROR_FILE}" 2>&1 > /dev/null
    status_stop_spinner "Finished setting basic preferences"
    exit_on_fail "basic preferences failed" "${E_PREFERENCE_FAILURE}"

    start_spinner "Setting ssd preferences"
    ssd_preferences >> "${ERROR_FILE}" 2>&1 > /dev/null
    status_stop_spinner "Finished setting ssd preferences"
    exit_on_fail "ssd preferences failed" "${E_PREFERENCE_FAILURE}"
}

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh"

    print_info "Setting general preferences"
    set_preferences
    status_no_exit "Finished setting general preferences"

    for app in "${APPS[@]}"; do
        if [[ -n "${app}" ]]; then
            killall "${app}" &> /dev/null
        fi
    done
    return 0
}

main
