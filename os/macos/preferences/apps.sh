#!/usr/bin/env bash
#
# Set other app preferences

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_PREFERENCE_FAILURE=101

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

declare -a APPS=(
    'Spectacle'
    'Transmission'
)

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

transmission_preferences() {
    # Use `~/Downloads/torrents` to store incomplete downloads
    defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
    defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads/torrents"

    # Use `~/Downloads` to store completed downloads
    # defaults write org.m0k.transmission DownloadLocationConstant -bool true

    # Don’t prompt for confirmation before downloading
    defaults write org.m0k.transmission DownloadAsk -bool false
    defaults write org.m0k.transmission MagnetOpenAsk -bool false

    # Don’t prompt for confirmation before removing non-downloading active transfers
    defaults write org.m0k.transmission CheckRemoveDownloading -bool true

    # Trash original torrent files
    defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

    # Hide the donate message
    defaults write org.m0k.transmission WarningDonate -bool false

    # Hide the legal disclaimer
    defaults write org.m0k.transmission WarningLegal -bool false

    # IP block list.
    # Source: https://giuliomac.wordpress.com/2014/02/19/best-blocklist-for-transmission/
    defaults write org.m0k.transmission BlocklistNew -bool true
    defaults write org.m0k.transmission BlocklistURL -string "http://john.bitsurge.net/public/biglist.p2p.gz"
    defaults write org.m0k.transmission BlocklistAutoUpdate -bool true

    # Randomize port on launch
    defaults write org.m0k.transmission RandomPort -bool true
}

sizeup_preferences() {
    # Start SizeUp at login
    defaults write com.irradiatedsoftware.SizeUp StartAtLogin -bool true

    # Don’t show the preferences window on next start
    defaults write com.irradiatedsoftware.SizeUp ShowPrefsOnNextStart -bool false
}

spectacle_preferences() {
    # Set up my preferred keyboard shortcuts
    cp -r "${HOME}/dotfiles/resources/spectacle.json" "${HOME}/Library/Application Support/Spectacle/Shortcuts.json" 2> /dev/null
}

archive_preferences() {
    # Move archive files to trash after expansion
    # Delete directly: "/dev/null"
    # Leave alone (default) "."
    defaults write com.apple.archiveutility dearchive-move-after -string "~/.Trash"
}

set_preferences() {
    start_spinner "Setting Transmission preferences"
    transmission_preferences >> "${ERROR_FILE}" 2>&1 > /dev/null
    status_stop_spinner "Finished setting Transmission preferences"
    exit_on_fail "Transmission preferences failed" "${E_PREFERENCE_FAILURE}"

    start_spinner "Setting Spectacle preferences"
    sizeup_preferences >> "${ERROR_FILE}" 2>&1 > /dev/null
    status_stop_spinner "Finished setting Spectacle preferences"
    exit_on_fail "Spectacle preferences failed" "${E_PREFERENCE_FAILURE}"

    start_spinner "Setting Spectacle preferences"
    spectacle_preferences >> "${ERROR_FILE}" 2>&1 > /dev/null
    status_stop_spinner "Finished setting Spectacle preferences"
    exit_on_fail "Spectacle preferences failed" "${E_PREFERENCE_FAILURE}"

    start_spinner "Setting Archive preferences"
    archive_preferences >> "${ERROR_FILE}" 2>&1 > /dev/null
    status_stop_spinner "Finished setting Archive preferences"
    exit_on_fail "Archive preferences failed" "${E_PREFERENCE_FAILURE}"
}

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh"

    print_info "Setting app preferences"
    set_preferences
    status_no_exit "Finished setting app preferences"

    for app in "${APPS[@]}"; do
        if [[ -n "${app}" ]]; then
            killall "${app}" &> /dev/null
        fi
    done
    return 0
}

main
