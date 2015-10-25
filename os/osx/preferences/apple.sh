#!/usr/bin/env bash
#
# Set preferences for apple tools and apps

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_PREFERENCE_FAILURE=101

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

declare -a APPS=(
    'Activity Monitor'
    'Address Book'
    'Calendar'
    'Contacts'
    'Mail'
    'Messages'
    'TextEdit'
)

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

spotlight_preferences() {
    # TODO: disabled by sip?
    # https://derflounder.wordpress.com/2015/10/01/system-integrity-protection-adding-another-layer-to-apples-security-model/
    # Hide Spotlight tray-icon (and subsequent helper)
    # sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search

    # Disable Spotlight indexing for any volume that gets mounted and has not yet
    # been indexed before.
    # Use `sudo mdutil -i off "/Volumes/foo"` to stop indexing any volume.
    sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"

    # Change indexing order and disable some search results
    # Yosemite-specific search results (remove them if your are using OS X 10.9 or older):
    #   MENU_DEFINITION
    #   MENU_CONVERSION
    #   MENU_EXPRESSION
    #   MENU_SPOTLIGHT_SUGGESTIONS (send search queries to Apple)
    #   MENU_WEBSEARCH             (send search queries to Apple)
    #   MENU_OTHER
    defaults write com.apple.spotlight orderedItems -array \
        '{"enabled" = 1;"name" = "APPLICATIONS";}' \
        '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
        '{"enabled" = 1;"name" = "DIRECTORIES";}' \
        '{"enabled" = 1;"name" = "PDF";}' \
        '{"enabled" = 1;"name" = "FONTS";}' \
        '{"enabled" = 0;"name" = "DOCUMENTS";}' \
        '{"enabled" = 0;"name" = "MESSAGES";}' \
        '{"enabled" = 0;"name" = "CONTACT";}' \
        '{"enabled" = 0;"name" = "EVENT_TODO";}' \
        '{"enabled" = 0;"name" = "IMAGES";}' \
        '{"enabled" = 0;"name" = "BOOKMARKS";}' \
        '{"enabled" = 0;"name" = "MUSIC";}' \
        '{"enabled" = 0;"name" = "MOVIES";}' \
        '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
        '{"enabled" = 0;"name" = "SPREADSHEETS";}' \
        '{"enabled" = 0;"name" = "SOURCE";}' \
        '{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
        '{"enabled" = 0;"name" = "MENU_OTHER";}' \
        '{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
        '{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
        '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
        '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'
    # Load new settings before rebuilding the index
    killall mds &> /dev/null
    # Make sure indexing is enabled for the main volume
    sudo mdutil -i on / >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
    # Rebuild the index from scratch
    sudo mdutil -E / >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
}

mail_preferences() {
    # Disable send and reply animations in Mail.app
    defaults write com.apple.mail DisableReplyAnimations -bool true
    defaults write com.apple.mail DisableSendAnimations -bool true

    # Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
    defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

    # Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app
    defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" -string "@\\U21a9"

    # TODO: ?
    # Display emails in threaded mode, sorted by date (oldest at the top)
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes"
    defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

    # Disable inline attachments (just show the icons)
    defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

    # Disable automatic spell checking
    defaults write com.apple.mail SpellCheckingBehavior -string "NoSpellCheckingEnabled"
}

timemachine_preferences() {
    # Prevent Time Machine from prompting to use new hard drives as backup volume
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

    # Disable local Time Machine backups
    hash tmutil &> /dev/null && sudo tmutil disablelocal
}

activity_preferences() {
    # Show the main window when launching Activity Monitor
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

    # Visualize CPU usage in the Activity Monitor Dock icon
    defaults write com.apple.ActivityMonitor IconType -int 5

    # Show all processes in Activity Monitor
    defaults write com.apple.ActivityMonitor ShowCategory -int 0

    # Sort Activity Monitor results by CPU usage
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0
}

utility_preferences() {
    # Enable the debug menu in Address Book
    defaults write com.apple.addressbook ABShowDebugMenu -bool true

    # Use plain text mode for new TextEdit documents
    defaults write com.apple.TextEdit RichText -int 0

    # Open and save files as UTF-8 in TextEdit
    defaults write com.apple.TextEdit PlainTextEncoding -int 4
    defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

    # Enable the debug menu in Disk Utility
    defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
    defaults write com.apple.DiskUtility advanced-image-options -bool true
}

appstore_preferences() {
    # Enable the WebKit Developer Tools in the Mac App Store
    defaults write com.apple.appstore WebKitDeveloperExtras -bool true

    # Enable Debug Menu in the Mac App Store
    defaults write com.apple.appstore ShowDebugMenu -bool true
}

messages_preferences() {
    # Disable automatic emoji substitution (i.e. use plain text smileys)
    defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

    # Disable smart quotes
    defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

    # Disable continuous spell checking
    defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false
}

set_preferences() {
    start_spinner "Setting Spotlight preferences"
    spotlight_preferences >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
    status_stop_spinner "Finished setting Spotlight preferences"
    exit_on_fail "Spotlight preferences failed" "${E_PREFERENCE_FAILURE}"

    start_spinner "Setting Mail preferences"
    mail_preferences >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
    status_stop_spinner "Finished setting Mail preferences"
    exit_on_fail "Mail preferences failed" "${E_PREFERENCE_FAILURE}"

    start_spinner "Setting Time Machine preferences"
    timemachine_preferences >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
    status_stop_spinner "Finished setting Time Machine preferences"
    exit_on_fail "Time Machine preferences failed" "${E_PREFERENCE_FAILURE}"

    start_spinner "Setting Activity Monitor preferences"
    activity_preferences >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
    status_stop_spinner "Finished setting Activity Monitor preferences"
    exit_on_fail "Activity Monitor preferences failed" "${E_PREFERENCE_FAILURE}"

    start_spinner "Setting utility preferences"
    utility_preferences >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
    status_stop_spinner "Finished setting utility preferences"
    exit_on_fail "utility preferences failed" "${E_PREFERENCE_FAILURE}"

    start_spinner "Setting Appstore preferences"
    appstore_preferences >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
    status_stop_spinner "Finished setting Appstore preferences"
    exit_on_fail "Appstore preferences failed" "${E_PREFERENCE_FAILURE}"

    start_spinner "Setting Messages preferences"
    messages_preferences >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
    status_stop_spinner "Finished setting Messages preferences"
    exit_on_fail "Messages preferences failed" "${E_PREFERENCE_FAILURE}"
}

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh"

    print_info "Setting preferences for apple apps"

    set_preferences

    for app in "${APPS[@]}"; do
        if [[ -n "${app}" ]]; then
            killall "${app}" &> /dev/null
        fi
    done

    status_no_exit "Finished setting apple preferences"
}

main
