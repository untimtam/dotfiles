#!/usr/bin/env bash
#
# Install homebrew and necessary tools

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_BREW_FAILURE=101

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

declare -r -a HOMEBREW_CASK_APPS=(
    '1password'
    'alfred'
    'android-file-transfer'
    'android-ndk'
    'android-platform-tools'
    'android-sdk'
    'android-studio'
    'android-studio-canary'
    'appcleaner'
    'arduino'
    'atom'
    'bartender'
    'caffeine'
    'championify'
    'couleurs'
    'discord'
    'docker'
    'easyvpn'
    'firefox'
    'franz'
    'gitkraken'
    'google-chrome'
    'google-cloud-sdk'
    'grandperspective'
    'iterm2'
    'java'
    'keyboard-cleaner'
    'league-of-legends'
    'logitech-gaming-software'
    'parallels-desktop'
    'postman'
    'skype'
    'slack'
    'sonos'
    'spectacle'
    'spotify'
    'steam'
    'sublime-text'
    'teamviewer'
    'the-unarchiver'
    'torbrowser'
    'transmission'
    'twitch'
    'unetbootin'
    'virtualbox'
    'vlc'
    'zeplin'
)

# -----------------------------------------------------------------------------
# | Homebrew                                                                   |
# -----------------------------------------------------------------------------

brew_tap() {
    declare -r REPOSITORY="$1"

    brew tap "${REPOSITORY}" &> /dev/null
    status_no_exit "brew tap ${REPOSITORY}"

    return $?
}

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

# Homebrew Casks
# https://github.com/caskroom/homebrew-cask
install_homebrew_apps() {
    if cmd_exists 'brew' && brew_tap 'caskroom/cask'; then
        if brew list "caskroom/cask/brew-cask" &> /dev/null; then
            print_success "cask already installed"
        else
            start_spinner "Installing cask"
            brew install "caskroom/cask/brew-cask" >> "${ERROR_FILE}" 2>&1 > /dev/null
            status_stop_spinner "Finished installing cask"
            exit_on_fail "cask installation failed" "${E_BREW_FAILURE}"
        fi
        print_separator
        for i in "${HOMEBREW_CASK_APPS[@]}"; do
            if [[ -n "$i" ]]; then
                if brew cask list "$i" &> /dev/null; then
                    print_success "$i already installed"
                else
                    start_spinner "Installing $i"
                    brew cask install "$i" >> "${ERROR_FILE}" 2>&1 > /dev/null
                    status_stop_spinner "Finished installing $i"
                    # exit_on_fail "$i installation failed" "${E_BREW_FAILURE}"
                fi
            fi
        done
    fi
}

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh"

    # cask apps
    install_homebrew_apps
    exit_on_fail "homebrew failed (cask)"
    print_separator
}

main
