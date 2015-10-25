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

# TODO: clean up installs with taps (i.e. homebrew/dupes)
declare -r -a HOMEBREW=(
    'bash'
    'zsh'
    'zsh-completions'

    # TODO: some more setup for some of these tools after? i.e. go, python, etc
    'python'
    'python3'
    'lua'
    'ocaml'
    'opam'
    'rust'
    'go'

    'tree'
    'fasd'
    'tmux'
    'pandoc'

    'vim'
    'git'
    'git-lfs'

    'speedtest_cli'
    'heroku-toolbelt'

    # Still evaluating these
    'imagemagick'
    'wget'
    'ack'
    'rename'
    'zopfli'
)
declare -r -a HOMEBREW_OPTS=(
    ['vim']='--override-system-vi'
    ['imagemagick']='--with-webp'
    ['wget']='--with-iri'
)
declare -r -a HOMEBREW_VERSIONS=(
    'bash-completion2'
)
declare -r -a HOMEBREW_CASK_QL=(
    'qlcolorcode'
    'qlstephen'
    'qlmarkdown'
    'quicklook-json'
    'betterzipql'
    'suspicious-package'
)
declare -r -a HOMEBREW_FONTS=(
    'font-source-code-pro-for-powerline'
    'font-source-code-pro'
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

# Homebrew
install_homebrew() {
    if ! cmd_exists 'brew'; then
        printf "\n" | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &> /dev/null
        #  └─ simulate the ENTER keypress
    fi
    status "Homebrew" "${E_BREW_INSTALL_FAILURE}"
}

# Homebrew Formulae
# https://github.com/Homebrew/homebrew
install_homebrew_formulae() {
    if cmd_exists 'brew'; then
        for i in "${HOMEBREW[@]}"; do
            if [[ -n "$i" ]]; then
                if brew list "$i" &> /dev/null; then
                    print_success "$i is already installed"
                else
                    start_spinner "Installing $i"
                    if [[ -n "${HOMEBREW_OPTS[$i]}" ]]; then
                        brew install "$i" "${HOMEBREW_OPTS[$i]}" >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
                    else
                        brew install "$i" >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
                    fi
                    status_stop_spinner "Finished installing $i"
                    exit_on_fail "$i installation failed" "${E_BREW_FAILURE}"
                fi
            fi
        done
    fi
}

# Homebrew Versions Formulae
# https://github.com/Homebrew/homebrew-versions
install_homebrew_formulae_versions() {
    if cmd_exists 'brew' && brew_tap 'homebrew/versions'; then
        for i in "${HOMEBREW_VERSIONS[@]}"; do
            if [[ -n "$i" ]]; then
                if brew list "$i" &> /dev/null; then
                    print_success "$i already installed"
                else
                    start_spinner "Installing $i"
                    brew install "$i" >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
                    status_stop_spinner "Finished installing $i"
                    exit_on_fail "$i installation failed" "${E_BREW_FAILURE}"
                fi
            fi
        done
    fi
}

# Homebrew Casks
# https://github.com/caskroom/homebrew-cask
install_homebrew_cask() {
    if cmd_exists 'brew' && brew_tap 'caskroom/cask'; then
        if brew list "caskroom/cask/brew-cask" &> /dev/null; then
            print_success "cask already installed"
        else
            start_spinner "Installing cask"
            brew install "caskroom/cask/brew-cask" >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
            status_stop_spinner "Finished installing cask"
            exit_on_fail "cask installation failed" "${E_BREW_FAILURE}"
        fi
        print_separator
        for i in "${HOMEBREW_CASK_QL[@]}"; do
            if [[ -n "$i" ]]; then
                if brew cask list "$i" &> /dev/null; then
                    print_success "$i already installed"
                else
                    start_spinner "Installing $i"
                    brew cask install "$i" >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
                    status_stop_spinner "Finished installing $i"
                    exit_on_fail "$i installation failed" "${E_BREW_FAILURE}"
                fi
            fi
        done
    fi
}

# Homebrew Cask Fonts
# https://github.com/caskroom/homebrew-fonts
install_homebrew_font() {
    if cmd_exists 'brew' && cmd_exists 'brew-cask' && brew_tap 'caskroom/fonts'; then
        for i in "${HOMEBREW_FONTS[@]}"; do
            if [[ -n "$i" ]]; then
                if brew cask list "$i" &> /dev/null; then
                    print_success "$i already installed"
                else
                    start_spinner "Installing $i"
                    brew cask install "$i" >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null
                    status_stop_spinner "Finished installing $i"
                    exit_on_fail "$i installation failed" "${E_BREW_FAILURE}"
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

    # first thing's first
    install_homebrew
    exit_on_fail "Homebrew install failed"
    print_separator

    # install homebrew tools
    install_homebrew_formulae
    exit_on_fail "homebrew failed (homebrew)"
    print_separator

    # alternate homebrew tools
    install_homebrew_formulae_versions
    exit_on_fail "homebrew failed (homebrew/versions)"
    print_separator

    # cask apps
    install_homebrew_cask
    exit_on_fail "homebrew failed (cask)"
    print_separator

    # homebrew fonts
    install_homebrew_font
    exit_on_fail "homebrew failed (cask fonts)"
    print_separator
}

main