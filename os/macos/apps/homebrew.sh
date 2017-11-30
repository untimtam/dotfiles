#!/usr/bin/env bash
#
# Install homebrew and necessary tools

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_BREW_INSTALL_FAILURE=101
declare -r E_BREW_FAILURE=102

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

declare -r -a TAPS=(
    'homebrew/versions'
    'caskroom/cask'
    'caskroom/versions'
    'caskroom/fonts'
    'caskroom/drivers'
)

declare -r -a SHELLS=(
    'bash'
    'bash-completion2'
    'zsh'
    'zsh-completions'
)

declare -r -a LANGS=(
    'python'
    'python3'
)

declare -r -a CASK_LANGS=(
    'java8'
)

declare -r -a TOOLS=(
    'brew-pip'
    'fasd'
    'git'
    'git-lfs'
    'gradle'
    'pandoc'
    'pidcat'
    'proguard'
    'tmux'
    'tree'
    'vim'
    'wget'
)

declare -r -a TOOL_OPTS=(
    ['vim']='--with-override-system-vi'
    ['wget']='--with-iri'
)

declare -r -a APPS=(
    '1password'
    'alfred'
    'android-ndk'
    'android-sdk'
    'android-studio'
    'appcleaner'
    'arduino'
    'atom'
    'bartender'
    'caffeine'
    'couleurs'
    'discord'
    'docker'
    'firefox'
    'franz'
    'gitkraken'
    'google-chrome'
    'google-cloud-sdk'
    'grandperspective'
    'iterm2'
    'keyboard-cleaner'
    'postman'
    'sizeup'
    'skype'
    'slack'
    'sonos'
    'spectacle'
    'spotify'
    'sublime-text'
    'teamviewer'
    'the-unarchiver'
    'torbrowser'
    'transmission'
    'tunnelblick'
    'twitch'
    'vlc'
    'zeplin'
)

declare -r -a FONTS=(
    'font-source-code-pro-for-powerline'
    'font-source-code-pro'
    'font-fontawesome'
    'font-roboto'
)

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

_install() {
    if "$2"; then
        _cask_install "$1" "$3"
    else
        _brew_install "$1" "$3"
    fi
}

_brew_install() {
    if brew list "$1" &> /dev/null; then
        print_success "$1 is already installed"
    else
        start_spinner "Installing $1"
        if [[ -n "$2" ]]; then
            brew install "$1" "$2" >> "${ERROR_FILE}" 2>&1 > /dev/null
        else
            brew install "$1" >> "${ERROR_FILE}" 2>&1 > /dev/null
        fi
        status_stop_spinner "Finished installing $1"
    fi
}

_cask_install() {
    if brew cask list "$1" &> /dev/null; then
        print_success "$1 is already installed"
    else
        start_spinner "Installing $1"
        if [[ -n "$2" ]]; then
            brew cask install "$1" "$2" >> "${ERROR_FILE}" 2>&1 > /dev/null
        else
            brew cask install "$1" >> "${ERROR_FILE}" 2>&1 > /dev/null
        fi
        status_stop_spinner "Finished installing $1"
    fi
}

# Homebrew
install_homebrew() {
    if ! cmd_exists 'brew'; then
        printf "\n" | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &> /dev/null
        #  └─ simulate the ENTER keypress
    fi
    status "Homebrew" "${E_BREW_INSTALL_FAILURE}"
}

# Homebrew taps
homebrew_taps() {
    if cmd_exists 'brew'; then
        for i in "${TAPS[@]}"; do
            if [[ -n "$i" ]]; then
                brew tap "$i" &> /dev/null
                status_no_exit "brew tap $i"
            fi
        done
    fi
}

install_shells() {
    if cmd_exists 'brew'; then
        for i in "${SHELLS[@]}"; do
            if [[ -n "$i" ]]; then
                _install "$i" false ""
            fi
        done
    fi
}

install_langs() {
    if cmd_exists 'brew'; then
        for i in "${LANGS[@]}"; do
            if [[ -n "$i" ]]; then
                _install "$i" false ""
            fi
        done
    fi
}

install_cask_langs() {
    if cmd_exists 'brew'; then
        for i in "${CASK_LANGS[@]}"; do
            if [[ -n "$i" ]]; then
                _install "$i" true ""
            fi
        done
    fi
}

install_tools() {
    if cmd_exists 'brew'; then
        for i in "${TOOLS[@]}"; do
            if [[ (-n "$i") && (-n "${TOOLS_OPTS[$i]}")]]; then
                _install "$i" false "${TOOLS_OPTS[$i]}"
            elif [[ -n "$i" ]]; then
                _install "$i" false ""
            fi
        done
    fi
}

install_apps() {
    if cmd_exists 'brew'; then
        for i in "${APPS[@]}"; do
            if [[ -n "$i" ]]; then
                _install "$i" true ""
            fi
        done
    fi
}

install_fonts() {
    if cmd_exists 'brew'; then
        for i in "${FONTS[@]}"; do
            if [[ -n "$i" ]]; then
                _install "$i" true ""
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

    # first thing's first
    install_homebrew
    exit_on_fail "Homebrew installed"
    print_separator

    # taps
    homebrew_taps
    exit_on_fail "Homebrew installed"
    print_separator

    # shells
    install_shells
    print_separator

    # langs
    install_langs
    install_cask_langs
    print_separator

    # tools
    install_tools
    print_separator

    # apps
    install_apps
    print_separator

    # fonts
    install_fonts
    print_separator
}

main
