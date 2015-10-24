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
    'macvim'
    'basictex'
    'heroku-toolbelt'

    'caffeine'
    'flux'
    'grandperspective'
    'the-unarchiver'
    'couleurs'
    'appcleaner'
    'liteicon'
    'spectacle'
)

# -----------------------------------------------------------------------------
# | Homebrew                                                                   |
# -----------------------------------------------------------------------------

brew_tap() {
    declare -r REPOSITORY="$1"

    brew tap "${REPOSITORY}" &> /dev/null
    status_no_exit "brew tap ${REPOSITORY}\n"

    return $?
}

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

# Homebrew Casks
# https://github.com/caskroom/homebrew-cask
install_homebrew_apps() {
    if cmd_exists 'brew' && brew_tap 'caskroom/cask'; then
        brew install "caskroom/cask/brew-cask"
        status "cask installed"
        print_separator
        for i in "${HOMEBREW_CASK_APPS[@]}"; do
            if [[ -n "$i" ]]; then
                if brew list "$i" &> /dev/null; then
                    print_success "$i already installed"
                else
                    brew cask install --appdir="/Applications" "$i" >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
                    status "$i installed" "${E_BREW_FAILURE}"
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
