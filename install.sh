#!/usr/bin/env bash
#
# Author: Tim Flichy
# Description: Install dotfiles with personal defaults.
# Version: 0.0.1
#

# region header
cat << EOF


     _       _
  __| | ___ | |_ ___
 / _\` |/ _ \\| __/ __|
| (_| | (_) | |_\\__ \\
 \\__,_|\\___/ \\__|___/



EOF

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Internal field separator
IFS=$'\n\t'

# endregion

# region exit codes

readonly SUCCESS=0

# system defined
# Note: exit codes 1 - 2, 126 - 165, and 255 have special meanings
#       see: http://tldp.org/LDP/abs/html/exitcodes.html
readonly E_GENERAL=1
readonly E_BUILTIN=2
readonly E_NOT_EXECUTABLE=126
readonly E_COMMAND_NOT_FOUND=127

# user defined
readonly E_NOT_IMPLEMENTED=100
readonly E_PARAMETER=101
readonly E_INPUT=102
readonly E_FILE_NOT_FOUND=103
readonly E_DOWNLOAD_FAILURE=104
readonly E_TAP_FAILURE=105
readonly E_INSTALL_FAILURE=106

# endregion

# region global variables

readonly LOG_FILE="$(pwd)/install.log"

readonly USERNAME_DEFAULT="hellowor1d"
readonly COMPUTER_NAME_DEFAULT="fenrir"
readonly DISK_NAME_DEFAULT="tesseract"

readonly SSH_KEY="${HOME}/.ssh/id_rsa"

readonly DIRECTORIES=(
  "${HOME}/Desktop"

  "${HOME}/Downloads"
  "${HOME}/Downloads/torrents"

  "${HOME}/Pictures/Wallpapers"
  "${HOME}/Pictures/Screenshots"

  "${HOME}/Repositories"

  "${HOME}/bin"

  # "${HOME}/focal"
)

readonly DOT_LINKS=(
  "shell/bash/bash_profile"
  "shell/bash/bashrc"

  "shell/zsh/zshrc"

  "shell/other/curlrc"
  "shell/other/wgetrc"
  "shell/other/inputrc"
  "shell/other/hushlogin"

  "tools/git/gitconfig"
  "tools/git/gitmessage"
  "tools/git/gitignore_global"

  "tools/tmux/tmux.conf"

  "tools/editor/editorconfig"
)

readonly ZSH_PROMPT_SOURCE="$(pwd)/shell/zsh/prompt_hellowor1d_setup"
readonly ZSH_PROMPT_TARGET="$(pwd)/shell/zsh/.zprezto/modules/prompt/functions/prompt_hellowor1d_setup"

readonly HOMEBREW_TAPS=(
  'homebrew/command-not-found'
  'caskroom/cask'
  'caskroom/versions'
  'caskroom/fonts'
  'caskroom/drivers'
)

readonly HOMEBREW_SHELLS=(
  'bash'
  'bash-completion2'
  'zsh'
  'zsh-completions'
)

readonly HOMEBREW_LANGS=(
  'node'
  'python@2'
  'python'
)

readonly CASK_LANGS=(
  'java'
  'java8'
)

readonly HOMEBREW_TOOLS=(
  'brew-pip'
  'docker'
  'fasd'
  'git'
  'git-lfs'
  'gradle'
  'imagemagick --with-webp'
  'jadx'
  'jupyter'
  'nativefier'
  'ngrep'
  'pandoc'
  'pidcat'
  'proguard'
  'shellcheck'
  'tmux'
  'tree'
  'vim --with-override-system-vi'
  'wget --with-iri'
)

readonly CASK_FONTS=(
  'font-fira-code'
  'font-fira-mono'
  'font-firacode-nerd-font'
  'font-firacode-nerd-font-mono'
  'font-fontawesome'
  'font-hack-nerd-font'
  'font-input'
  'font-roboto'
  'font-source-code-pro'
)

readonly CASK_APPS=(
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
  # 'championify'
  'couleurs'
  'discord'
  'docker'
  'etcher'
  'firefox'
  'franz'
  'gitkraken'
  'google-chrome'
  'google-cloud-sdk'
  'grandperspective'
  'iterm2'
  'keyboard-cleaner'
  # 'league-of-legends'
  'postman'
  'pycharm'
  'skype'
  'slack'
  'spectacle'
  'spotify'
  'sublime-text'
  'teamviewer'
  'the-unarchiver'
  'torbrowser'
  'transmission'
  'tunnelblick'
  # 'twitch'
  'unetbootin'
  'vlc'
  'webstorm'
  'zeplin'
)

readonly DOCK_APPS=(
  'System Preferences'
  'Calendar'
  'Mail'
  'Messages'
  'TextEdit'
)

readonly KILL_APPS=(
  'Activity Monitor'
  'Address Book'
  'Calendar'
  'cfprefsd'
  'Contacts'
  'Dock'
  'Finder'
  'Google Chrome'
  'iTerm'
  'Mail'
  'Messages'
  'Photos'
  'Safari'
  'Spectacle'
  'SystemUIServer'
  'Terminal'
  'TextEdit'
  'Transmission'
)

# endregion

# region helper functions

# region traps

# DESC: Handler for unexpected errors
# ARGS: $1 (optional): Exit code (defaults to 1)
# OUTS: None
function __trap_error() {
  local command_exit_code=$?
  local exit_code=$E_GENERAL

  # Disable the error trap handler to prevent potential recursion
  trap - ERR

  # Consider any further errors non-fatal to ensure we run to completion
  set +o errexit
  set +o pipefail

  # Validate any provided exit code
  if [[ ${1-} =~ ^[0-9]+$ ]]; then
    exit_code="$1"
  fi

  # Print basic debugging information
  printf '%b\n' "$ta_none"
  printf '***** Abnormal termination of script *****\n'
  printf 'Script Path:                    %s\n' "$script_path"
  printf 'Script Parameters:              %s\n' "$script_params"
  printf 'Script Exit Code:               %s\n' "$exit_code"
  printf 'Script Command Exit Code:       %s\n' "$command_exit_code"
  printf 'Script Line Number:             %s\n' "$LINENO"
  # $LINENO

  # Exit with failure status
  exit "$exit_code"
}

# DESC: Handler for exiting the script
# ARGS: None
# OUTS: None
function __trap_exit() {
  # Return to original working directory
  cd "$orig_cwd"

  # Restore terminal colors
  printf '%b' "$ta_none"
}

# DESC: Handler for killing the script
# ARGS: None
# OUTS: None
function __trap_kill() {
  pretty_print "Aborting..." "$fg_red"
  exit $E_GENERAL
}

# endregion

# region exit

# DESC: Exit script with the given message
# ARGS: $1 (required): Message to print on exit
#       $2 (optional): Exit code (defaults to 0)
# OUTS: None
function script_exit() {
  if [[ $# -eq 1 ]]; then
    printf '%s\n' "$1"
    exit $SUCCESS
  fi

  if [[ ${2-} =~ ^[0-9]+$ ]]; then
    printf '%b\n' "$1"
    # If we've been provided a non-zero exit code run the error trap
    if [[ $2 -ne 0 ]]; then
      __trap_error "$2"
    else
      exit $SUCCESS
    fi
  fi

  script_exit 'Missing required argument to script_exit()!' $E_BUILTIN
}

# endregion

# region init

# DESC: Generic script initialisation
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: $orig_cwd: The current working directory when the script was run
#       $script_path: The full path to the script
#       $script_dir: The directory path of the script
#       $script_name: The file name of the script
#       $script_params: The original parameters provided to the script
#       $ta_none: The ANSI control code to reset all text attributes
# NOTE: $script_path only contains the path that was used to call the script
#       and will not resolve any symlinks which may be present in the path.
#       You can use a tool like realpath to obtain the "true" path. The same
#       caveat applies to both the $script_dir and $script_name variables.
function script_init() {
  # Useful paths
  readonly orig_cwd="$PWD"
  readonly script_path="${BASH_SOURCE[0]}"
  readonly script_dir="$(dirname "$script_path")"
  readonly script_name="$(basename "$script_path")"
  readonly script_params="$*"

  # Important to always set as we use it in the exit handler
  readonly ta_none="$(tput sgr0 2> /dev/null || true)"

  return $SUCCESS
}

# DESC: Initialise color variables
# ARGS: None
# OUTS: Read-only variables with ANSI control codes
# NOTE: If --no-color was set the variables will be empty
function color_init() {
  if [[ -z ${no_color-} ]]; then
    # Text attributes
    readonly ta_bold="$(tput bold 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly ta_uscore="$(tput smul 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly ta_blink="$(tput blink 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly ta_reverse="$(tput rev 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly ta_conceal="$(tput invis 2> /dev/null || true)"
    printf '%b' "$ta_none"

    # Foreground codes
    readonly fg_black="$(tput setaf 0 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_blue="$(tput setaf 4 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_cyan="$(tput setaf 6 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_green="$(tput setaf 2 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_magenta="$(tput setaf 5 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_red="$(tput setaf 1 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_white="$(tput setaf 7 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_yellow="$(tput setaf 3 2> /dev/null || true)"
    printf '%b' "$ta_none"

    # Background codes
    readonly bg_black="$(tput setab 0 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_blue="$(tput setab 4 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_cyan="$(tput setab 6 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_green="$(tput setab 2 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_magenta="$(tput setab 5 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_red="$(tput setab 1 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_white="$(tput setab 7 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_yellow="$(tput setab 3 2> /dev/null || true)"
    printf '%b' "$ta_none"

    # log colors
    readonly color_verbose=''
    readonly color_debug="\\x1b[35m"
    readonly color_info="\\x1b[32m"
    readonly color_warn="\\x1b[33m"
    readonly color_error="\\x1b[31m"
    readonly color_emergency="\\x1b[1;4;5;33;41m"
  else
    # Text attributes
    readonly ta_bold=''
    readonly ta_uscore=''
    readonly ta_blink=''
    readonly ta_reverse=''
    readonly ta_conceal=''

    # Foreground codes
    readonly fg_black=''
    readonly fg_blue=''
    readonly fg_cyan=''
    readonly fg_green=''
    readonly fg_magenta=''
    readonly fg_red=''
    readonly fg_white=''
    readonly fg_yellow=''

    # Background codes
    readonly bg_black=''
    readonly bg_blue=''
    readonly bg_cyan=''
    readonly bg_green=''
    readonly bg_magenta=''
    readonly bg_red=''
    readonly bg_white=''
    readonly bg_yellow=''

    # log colors
    readonly color_verbose=''
    readonly color_debug=''
    readonly color_info=''
    readonly color_warn=''
    readonly color_error=''
    readonly color_emergency=''
  fi

  return $SUCCESS
}

# endregion

# region parse parameters/arguments

# DESC: Usage help
# ARGS: None
# OUTS: None
function script_usage() {
    cat << EOF
Usage:
     -h|--help                  Displays this help
     -v|--verbose               Displays verbose output
     -d|--dry-run               Runs without making any changes
     -n|--no-color              Disables color output
     -t|--traces                Enable traces
EOF

  return $SUCCESS
}

# DESC: Parameter parser
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: Variables indicating command-line parameters and options
function parse_params() {
  local param
  while [[ $# -gt 0 ]]; do
    param="$1"
    shift
    case $param in
      -h|--help)
        script_usage
        exit $SUCCESS
        ;;
      -d|--dry-run)
        dry_run=true
        ;;
      -v|--verbose)
        verbose=true
        ;;
      -n|--no-color)
        no_color=true
        ;;
      -t|--traces)
        # Turn on traces, useful while debugging
        set -o xtrace
        ;;
      *)
        echo "Invalid parameter was provided: $param"
        exit $E_PARAMETER
        ;;
    esac
  done

  return $SUCCESS
}

# endregion

# region io

# DESC: Pretty print the provided string
# ARGS: $1 (required): Message to print (defaults to a green foreground)
#       $2 (optional): Foreground color to print the message with. This can be an ANSI
#                      escape code or one of the prepopulated color variables.
#       $3 (optional): Background color to print the message with. This can be an ANSI
#                      escape code or one of the prepopulated color variables.
#       $4 (optional): Set to any value to not append a new line to the message
# OUTS: None
function pretty_print() {
    if [[ $# -lt 1 ]]; then
      script_exit 'Missing required argument to pretty_print()!' $E_BUILTIN
    fi

    if [[ -z ${no_color-} ]]; then
      if [[ -n ${2-} ]]; then
        printf '%b' "$2"
      else
        printf '%b' "$fg_green"
      fi
      if [[ -n ${3-} ]]; then
        printf '%b' "$3"
      fi
    fi

    # Print message & reset text attributes
    if [[ -n ${4-} ]]; then
      printf '%s%b' "$1" "$ta_none"
    else
      printf '%s%b\n' "$1" "$ta_none"
    fi

    return $SUCCESS
}

# DESC: Log the provided message
# ARGS: $1 (required): Log level (defaults to error)
#       $2 (required): Message to log
# OUTS: None
function __log() {
  if [[ $# -lt 2 ]]; then
    script_exit 'Missing required argument to __log()!' $E_BUILTIN
  fi

  local log_level="${1}"
  local colorvar="color_${log_level}"
  pretty_print "[$(date -u +"%Y-%m-%d %H:%M:%S UTC") - ${log_level}] ${2}" "${!colorvar:-${ta_none}}"
  return $SUCCESS
}

# DESC: Log verbose messages, only if verbose mode is enabled
# ARGS: $@ (optional): Arguments provided to log
# OUTS: None
function verbose() {
  if [[ -n ${verbose-} ]]; then
    __log verbose "$@"
  fi
  return $SUCCESS
}

# DESC: Log debug messages
# ARGS: $@ (optional): Arguments provided to log
# OUTS: None
function debug() {
  __log debug "$@"
  return $SUCCESS
}

# DESC: Log info messages
# ARGS: $@ (optional): Arguments provided to log
# OUTS: TODO
function info() {
  __log info "$@"
  return $SUCCESS
}

# DESC: Log warn messages
# ARGS: $@ (optional): Arguments provided to log
# OUTS: None
function warn() {
  __log warn "$@"
  return $SUCCESS
}

# DESC: Log error messages
# ARGS: $@ (optional): Arguments provided to log
# OUTS: None
function error() {
  __log error "$@"
  return $SUCCESS
}

# DESC: Log emergency messages and then exit
# ARGS: $@ (optional): Arguments provided to log
# OUTS: None
function emergency() {
  __log emergency "$@"
  return $E_GENERAL;
}

# DESC: Prompt user for a response
# ARGS: $1 (required): Prompt
#       $2 (optional): Set to any value to allow defaults
# OUTS: $PROMPT: result
function prompt() {
  pretty_print "$1 : " "$fg_cyan"
  # shellcheck disable=SC2162
  read

  if [[ -n "${REPLY-}" || -n ${2-} ]]; then
    PROMPT="${REPLY}"
    return $SUCCESS
  else
    prompt "$1"
  fi
}

# DESC: Prompt user for (y/n) response
# ARGS: $1 (required): Prompt
# OUTS: $CONFIRM: 'y' or 'n' depending on user input
function confirm() {
  pretty_print "$1 (y/n): " "$fg_cyan"
  # shellcheck disable=SC2162
  read -n 1
  printf '\n'

  if [[ "${REPLY}" =~ ^[YyNn]$ ]]; then
    if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
      CONFIRM='y'
      return $SUCCESS
    else
      CONFIRM='n'
      return $SUCCESS
    fi
  else
    confirm "$1"
  fi
}

# endregion

# endregion

# region prompts

# DESC: Prompt for user inputs
# ARGS: None
# OUTS: $USER_FIRST_NAME: User first name
#       $USER_LAST_NAME: User last name
#       $USER_FULL_NAME: User full name (first and last)
#       $USER_EMAIL: User email
#       $USER_NAME: Username (defaults to "hellowor1d")
#       $COMPUTER_NAME: Computer name (defaults to "fenrir")
#       $DISK_NAME: Disk name (defaults to "tesseract")
function prompt_inputs() {
  verbose "entering prompt_inputs"

  prompt "First Name? [required]"
  readonly USER_FIRST_NAME="${PROMPT}"

  prompt "Last Name? [required]"
  readonly USER_LAST_NAME="${PROMPT}"

  readonly USER_FULL_NAME="${USER_FIRST_NAME} ${USER_LAST_NAME}"

  prompt "Email? [required]"
  readonly USER_EMAIL="${PROMPT}"

  prompt "Username? (${USERNAME_DEFAULT})" 0
  readonly USERNAME="${PROMPT:-$USERNAME_DEFAULT}"

  prompt "Computer Name? (${COMPUTER_NAME_DEFAULT})" 0
  readonly COMPUTER_NAME="${PROMPT:-$COMPUTER_NAME_DEFAULT}"

  prompt "Disk Name? (${DISK_NAME_DEFAULT})" 0
  readonly DISK_NAME="${PROMPT:-$DISK_NAME_DEFAULT}"

  pretty_print "Inputs:"
  pretty_print "Full Name: $USER_FULL_NAME" "$fg_white"
  pretty_print "Email: $ta_uscore$USER_EMAIL" "$fg_white"
  pretty_print "Username: $ta_bold$USERNAME" "$fg_white"
  pretty_print "Computer: $COMPUTER_NAME" "$fg_white"
  pretty_print "Disk: $DISK_NAME" "$fg_white"

  confirm "Continue?"

  if [[ "${CONFIRM}" =~ ^[n]$ ]]; then
    script_exit 'Aborted after input' $E_INPUT
  fi

  verbose "exiting prompt_inputs"
  return $SUCCESS
}

# endregion

# region create ssh key

# DESC: Create an SSH key
# ARGS: None
# OUTS: None
function create_ssh_key() {
  verbose "entering create_ssh_key"

  info "creating ssh key for ${USER_EMAIL} (in $SSH_KEY)"
  if [[ ! -n ${dry_run-} ]]; then
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY" -N "" -C "${USER_EMAIL}"
    if ssh-agent -s &> /dev/null; then
      ssh-add "$SSH_KEY"
    fi
  fi

  verbose "exiting create_ssh_key"
  return $SUCCESS
}

# endregion

# region create directories

# DESC: Create common directories
# ARGS: None
# OUTS: None
function create_directories() {
  verbose "entering create_directories"

  for directory in "${DIRECTORIES[@]}"; do
    if [[ -n "${directory}" ]]; then
      info "making dir ${directory}"
      if [[ ! -n ${dry_run-} ]]; then
        mkdir -p "${directory}" &> /dev/null
      fi
    fi
  done

  verbose "exiting create_directories"
  return $SUCCESS
}

# endregion

# region create symlinks

# DESC: Create a symlink
# ARGS: $1 (required): source file
#       $2 (required): symlink target file
# OUTS: None
function create_symlink() {
  if [[ $# -lt 2 ]]; then
      script_exit 'Missing required argument to create_symlink()!' $E_BUILTIN
  fi

  local source_file="$1"
  local target_file="$2"

  # TODO test if target already exists?
  if [[ -e "${source_file}" ]]; then
    info "creating symlink ${target_file} → ${source_file}"
    if [[ ! -n ${dry_run-} ]]; then
      ln -fs "${source_file}" "${target_file}" &> /dev/null
    fi
  else
    script_exit "File ${source_file} not found" $E_FILE_NOT_FOUND
  fi

  return $SUCCESS
}

# DESC: Create all symlinks
# ARGS: None
# OUTS: None
function create_symlinks() {
  verbose "entering create_symlinks"

  local source_file=""
  local target_file=""

  for file in "${DOT_LINKS[@]}"; do
    if [[ -n ${file} ]]; then
      source_file="$(pwd)/${file}"
      # shellcheck disable=SC1117
      target_file="${HOME}/.$(printf "%s" "${file}" | sed "s/.*\/\(.*\)/\1/g")"
      # Note: dry-run handled in `create_symlink`
      create_symlink "${source_file}" "${target_file}"
    fi
  done

  create_symlink "${ZSH_PROMPT_SOURCE}" "${ZSH_PROMPT_TARGET}"

  verbose "exiting create_symlinks"
  return $SUCCESS
}

# endregion

#region homebrew

# DESC: Install and update homebrew
# ARGS: None
# OUTS: None
function install_homebrew() {
  verbose "entering install_homebrew"

  if ! command -v 'brew' &> /dev/null; then
    info "downloading and installing homebrew"
    if [[ ! -n ${dry_run-} ]]; then
      # shellcheck disable=SC1117
      printf "\n" | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &> /dev/null
      #  └─ simulate the ENTER keypress
      # shellcheck disable=SC2181
      if [[ $? -ne 0 ]]; then
        script_exit "Homebrew download and/or install failed" $E_DOWNLOAD_FAILURE
      fi
    fi
  else
    verbose "hombrew is already downloaded"
  fi

  verbose "exiting install_homebrew"
  return $SUCCESS
}

# DESC: Tap alternative sources for homebrew binaries
# ARGS: None
# OUTS: None
function homebrew_taps() {
  verbose "entering homebrew_taps"

  for tap in "${HOMEBREW_TAPS[@]}"; do
    if [[ -n ${tap} ]]; then
      info "tapping ${tap}"
      if [[ ! -n ${dry_run-} ]]; then
        if ! brew tap "${tap}" >> "${LOG_FILE}" 2>&1 > /dev/null; then
          script_exit "${tap} tap failed" $E_TAP_FAILURE
        fi
      fi
    fi
  done

  verbose "exiting homebrew_taps"
  return $SUCCESS
}

# DESC: Install alternative/updated shells
# ARGS: None
# OUTS: None
function install_shells() {
  verbose "entering install_shells"

  for shell in "${HOMEBREW_SHELLS[@]}"; do
    if [[ -n "${shell}" ]]; then
      info "installing ${shell}"
      if [[ ! -n ${dry_run-} ]]; then
        if ! brew install "$shell" >> "${LOG_FILE}" 2>&1 > /dev/null; then
          script_exit "${shell} install failed" $E_INSTALL_FAILURE
        fi
      fi
    fi
  done

  if grep '/usr/local/bin/bash' /etc/shells &> /dev/null ; then
    verbose 'adding /usr/local/bin/bash to /etc/shells'
    if [[ ! -n ${dry_run-} ]]; then
      sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells' &> /dev/null
    fi
  fi

  if grep '/usr/local/bin/zsh' /etc/shells &> /dev/null ; then
    verbose 'adding /usr/local/bin/zsh to /etc/shells'
    if [[ ! -n ${dry_run-} ]]; then
      sudo bash -c 'echo /usr/local/bin/zsh >> /etc/shells' &> /dev/null
    fi
  fi

  verbose "exiting install_shells"
  return $SUCCESS
}

# DESC: Install programming languages
# ARGS: None
# OUTS: None
function install_langs() {
  verbose "entering install_langs"

  # install language from homebrew
  for lang in "${HOMEBREW_LANGS[@]}"; do
    if [[ -n "${lang}" ]]; then
      info "installing ${lang}"
      if [[ ! -n ${dry_run-} ]]; then
        if ! brew install "$lang" >> "${LOG_FILE}" 2>&1 > /dev/null; then
          script_exit "${lang} install failed" $E_INSTALL_FAILURE
        fi
      fi
    fi
  done

  # install language from cask
  for lang in "${CASK_LANGS[@]}"; do
    if [[ -n "${lang}" ]]; then
      info "installing ${lang}"
      if [[ ! -n ${dry_run-} ]]; then
        if ! brew cask install "$lang" >> "${LOG_FILE}" 2>&1 > /dev/null; then
          script_exit "${lang} install failed" $E_INSTALL_FAILURE
        fi
      fi
    fi
  done

  verbose "exiting install_langs"
  return $SUCCESS
}

# DESC: Install command line tools/binaries
# ARGS: None
# OUTS: None
function install_tools() {
  verbose "entering install_tools"

  for tool in "${HOMEBREW_TOOLS[@]}"; do
    if [[ -n "${tool}" ]]; then
      info "installing ${tool}"
      if [[ ! -n ${dry_run-} ]]; then
        if ! brew install $tool >> "${LOG_FILE}" 2>&1 > /dev/null; then
          script_exit "${tool} install failed" $E_INSTALL_FAILURE
        fi
      fi
    fi
  done

  verbose "exiting install_tools"
  return $SUCCESS
}

# DESC: Install fonts
# ARGS: None
# OUTS: None
function install_fonts() {
  verbose "entering install_fonts"

  for font in "${CASK_FONTS[@]}"; do
    if [[ -n "$font" ]]; then
      info "installing ${font}"
      if [[ ! -n ${dry_run-} ]]; then
        if ! brew cask install "$font" >> "${LOG_FILE}" 2>&1 > /dev/null; then
          script_exit "${font} install failed" $E_INSTALL_FAILURE
        fi
      fi
    fi
  done

  verbose "exiting install_fonts"
  return $SUCCESS
}

# DESC: Install apps
# ARGS: None
# OUTS: None
function install_apps() {
  verbose "entering install_apps"

  for app in "${CASK_APPS[@]}"; do
    if [[ -n "${app}" ]]; then
      info "installing ${app}"
      if [[ ! -n ${dry_run-} ]]; then
        if ! brew cask install "$app" >> "${LOG_FILE}" 2>&1 > /dev/null; then
          script_exit "${app} install failed" $E_INSTALL_FAILURE
        fi
      fi
    fi
  done

  verbose "exiting install_apps"
  return $SUCCESS
}

# DESC: Install homebrew then install tools, apps, etc
# ARGS: None
# OUTS: None
function set_environment() {
  verbose "entering set_environment"

  # install_homebrew
  homebrew_taps

  # Update homebrew packages
  verbose "updating homebrew"
  if [[ ! -n ${dry_run-} ]]; then
    brew update >> "${LOG_FILE}" 2>&1 > /dev/null
  fi

  # Upgrade homebrew packages
  verbose "upgrading existing homebrew packages"
  if [[ ! -n ${dry_run-} ]]; then
    brew upgrade >> "${LOG_FILE}" 2>&1 > /dev/null
  fi

  install_shells
  install_langs
  install_tools
  install_fonts
  install_apps

  # Clean up homebrew packages
  verbose "cleaning up homebrew files"
  if [[ ! -n ${dry_run-} ]]; then
    brew cleanup >> "${LOG_FILE}" 2>&1 > /dev/null
  fi

  verbose "exiting set_environment"
  return $SUCCESS
}

# endregion

# region preferences

# DESC: Set global system preferences that don't have a category or it's unknown
# ARGS: None
# OUTS: None
function system_preferences() {
  verbose "entering system_preferences"

  # Set computer name (as done via System Preferences → Sharing)
  # ex: Jarvis, Mark I, box, abacus, scud
  sudo scutil --set ComputerName "${COMPUTER_NAME}"
  sudo scutil --set HostName "${COMPUTER_NAME}"
  sudo scutil --set LocalHostName "${COMPUTER_NAME}"
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${COMPUTER_NAME}"

  # Disable the sound effects on boot
  sudo nvram SystemAudioVolume=" "

  # Require password immediately after sleep or screen saver begins
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0

  # Restart automatically if the computer freezes
  sudo systemsetup -setrestartfreeze on

  # Disable Resume system-wide
  defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

  # Menu bar
  defaults write com.apple.systemuiserver menuExtras -array \
    "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
    "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
    "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
    "/System/Library/CoreServices/Menu Extras/Battery.menu" \
    "/System/Library/CoreServices/Menu Extras/Volume.menu" \
    "/System/Library/CoreServices/Menu Extras/Clock.menu" \
    "/System/Library/CoreServices/Menu Extras/User.menu"

  # hide remaining battery time, show percentage.
  defaults write com.apple.menuextra.battery ShowPercent -string "YES"
  defaults write com.apple.menuextra.battery ShowTime -string "NO"

  # Increase window resize speed for Cocoa applications
  defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

  # Disable the “Are you sure you want to open this application?” dialog
  defaults write com.apple.LaunchServices LSQuarantine -bool false

  # Remove duplicates in the “Open With” menu (also see `lscleanup` alias)
  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

  # Disable automatic termination of inactive apps
  defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

  # Set Help Viewer windows to non-floating mode
  defaults write com.apple.helpviewer DevMode -bool true

  # Reveal IP address, hostname, OS version, etc. when clicking the clock
  # in the login window
  sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

  # Save screenshots to Pictures/Screenshots
  defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"

  # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
  defaults write com.apple.screencapture type -string "png"

  # Disable shadow in screenshots
  defaults write com.apple.screencapture disable-shadow -bool true

  # Enable the debug menu in Disk Utility
  defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
  defaults write com.apple.DiskUtility advanced-image-options -bool true

  verbose "exiting system_preferences"
  return $SUCCESS
}

# DESC: Set disk preferences
# ARGS: None
# OUTS: None
function disk_preferences() {
  verbose "entering disk_preferences"

  # Set disk name
  diskutil rename / "${DISK_NAME}"

  # Disable local Time Machine snapshots
  # sudo tmutil disablelocal

  # Disable hibernation (speeds up entering sleep mode)
  sudo pmset -a hibernatemode 0

  # Disable the sudden motion sensor as it’s not useful for SSDs
  sudo pmset -a sms 0

  # Save to disk (not to iCloud) by default
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

  verbose "exiting disk_preferences"
  return $SUCCESS
}

# DESC: Set system preferences in the General pane
# ARGS: None
# OUTS: None
function general_preferences() {
  verbose "entering general_preferences"

  # Set highlight color
  # Aqua
  defaults write NSGlobalDomain AppleHighlightColor -string "0.000000 0.673776 0.999931"
  # Green "0.764700 0.976500 0.568600"
  # Graphite "0.780400 0.815700 0.858800"

  # Always show scrollbars
  # Possible values: `WhenScrolling`, `Automatic` and `Always`
  defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

  verbose "exiting general_preferences"
  return $SUCCESS
}

# DESC: Set system preferences in the Dock pane
# ARGS: None
# OUTS: None
function dock_preferences() {
  verbose "entering dock_preferences"

  # Enable dark menu bar and dock
  defaults write NSGlobalDomain AppleInterfaceStyle Dark

  # Mimize application on double-click
  defaults write NSGlobalDomain AppleActionOnDoubleClick Minimize

  # Enable highlight hover effect for the grid view of a stack (Dock)
  defaults write com.apple.dock mouse-over-hilite-stack -bool true

  # Set the icon size of Dock items to 24 pixels
  defaults write com.apple.dock tilesize -int 24

  # Change minimize/maximize window effect
  defaults write com.apple.dock mineffect -string "scale"

  # Minimize windows into their application’s icon
  defaults write com.apple.dock minimize-to-application -bool true

  # Enable spring loading for all Dock items
  defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

  # Show indicator lights for open applications in the Dock
  defaults write com.apple.dock show-process-indicators -bool true

  # Don’t animate opening applications from the Dock
  defaults write com.apple.dock launchanim -bool false

  # Speed up Mission Control animations
  defaults write com.apple.dock expose-animation-duration -float 0.1

  # Group windows by application in Mission Control
  # (i.e. dont use the old Exposé behavior)
  defaults write com.apple.dock expose-group-by-app -bool true

  # Disable Dashboard
  defaults write com.apple.dashboard mcx-disabled -bool true

  # Don’t show Dashboard as a Space
  defaults write com.apple.dock dashboard-in-overlay -bool true

  # Don’t automatically rearrange Spaces based on most recent use
  defaults write com.apple.dock mru-spaces -bool false

  # Remove the auto-hiding Dock delay
  defaults write com.apple.dock autohide-delay -float 0

  # Remove the animation when hiding/showing the Dock
  defaults write com.apple.dock autohide-time-modifier -float 0

  # Automatically hide and show the Dock
  defaults write com.apple.dock autohide -bool true

  # Dont make Dock icons of hidden applications translucent
  defaults write com.apple.dock showhidden -bool false

  # Dont make Dock more transparent
  defaults write com.apple.dock hide-mirror -bool true

  # Reset Launchpad, but keep the desktop wallpaper intact
  find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete

  # Wipe all (default) app icons from the Dock
  # This is only really useful when setting up a new Mac, or if you don’t use
  # the Dock to launch apps.
  defaults write com.apple.dock persistent-apps -array
  # defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
  for dock_app in "${DOCK_APPS[@]}"; do
    defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/${dock_app}.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
  done

  # Hot corners
  # Possible values:
  #  0: no-op
  #  2: Mission Control
  #  3: Show application windows
  #  4: Desktop
  #  5: Start screen saver
  #  6: Disable screen saver
  #  7: Dashboard
  # 10: Put display to sleep
  # 11: Launchpad
  # 12: Notification Center
  # Top left screen corner → Mission Control
  # defaults write com.apple.dock wvous-tl-corner -int 2
  # defaults write com.apple.dock wvous-tl-modifier -int 0
  # Top right screen corner → Desktop
  # defaults write com.apple.dock wvous-tr-corner -int 4
  # defaults write com.apple.dock wvous-tr-modifier -int 0
  # Bottom left screen corner → Start screen saver
  # defaults write com.apple.dock wvous-bl-corner -int 5
  # defaults write com.apple.dock wvous-bl-modifier -int 0

  # Lock dock size and position
  defaults write com.apple.Dock position-immutable -bool yes
  defaults write com.apple.Dock size-immutable -bool yes

  verbose "exiting dock_preferences"
  return $SUCCESS
}

# DESC: Set system preferences in the Language pane
# ARGS: None
# OUTS: None
function language_preferences() {
  verbose "entering language_preferences"

  # Set language and text formats
  defaults write NSGlobalDomain AppleLanguages -array "en" "fr"
  defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
  defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
  defaults write NSGlobalDomain AppleMetricUnits -bool true

  # Set the timezone; see `sudo systemsetup -listtimezones` for other values
  # shellcheck disable=SC2024
  sudo systemsetup -settimezone "America/Los_Angeles" >> "${LOG_FILE}" 2>&1 > /dev/null

  # set 24 hour time
  defaults write NSGlobalDomain AppleICUForce24HourTime -bool true

  verbose "exiting language_preferences"
  return $SUCCESS
}

# DESC: Set system preferences in the Spotlight pane
# ARGS: None
# OUTS: None
function spotlight_preferences() {
  verbose "entering spotlight_preferences"

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
  # shellcheck disable=SC2024
  sudo mdutil -i on / >> "${LOG_FILE}" 2>&1 > /dev/null

  # Rebuild the index from scratch
  # shellcheck disable=SC2024
  sudo mdutil -E / >> "${LOG_FILE}" 2>&1 > /dev/null

  verbose "exiting spotlight_preferences"
  return $SUCCESS
}

# DESC: Set system preferences in the Display pane
# ARGS: None
# OUTS: None
function display_preferences() {
  verbose "entering display_preferences"

  # Enable subpixel font rendering on non-Apple LCDs
  # Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
  defaults write NSGlobalDomain AppleFontSmoothing -int 1

  # Enable HiDPI display modes (requires restart)
  sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

  verbose "exiting display_preferences"
  return $SUCCESS
}

# DESC: Set system preferences in the Energy pane
# ARGS: None
# OUTS: None
function energy_preferences() {
  verbose "entering energy_preferences"

  # Set standby delay to 24 hours (default is 1 hour)
  sudo pmset -a standbydelay 86400

  # Never go into computer sleep mode
  # shellcheck disable=SC2024
  sudo systemsetup -setcomputersleep Off >> "${LOG_FILE}" 2>&1 > /dev/null

  verbose "exiting energy_preferences"
  return $SUCCESS
}

# DESC: Set system preferences in the Keyboard pane
# ARGS: None
# OUTS: None
function keyboard_preferences() {
  verbose "entering keyboard_preferences"

  # Enable full keyboard access for all controls
  # (e.g. enable Tab in modal dialogs)
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

  # Use scroll gesture with the Ctrl (^) modifier key to zoom
  defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
  defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

  # Follow the keyboard focus while zoomed in
  defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

  # Zoom should use nearest neighbor instead of smoothing.
  defaults write com.apple.universalaccess 'closeViewSmoothImages' -bool false

  # Disable press-and-hold for keys in favor of key repeat
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

  # Set a blazingly fast keyboard repeat rate
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 10

  # Disable smart quotes
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

  # Disable smart dashes
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  # Disable auto-correct
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

  # Stop iTunes from responding to the keyboard media keys
  launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

  # Automatically illuminate built-in MacBook keyboard in low light
  defaults write com.apple.BezelServices kDim -bool true
  # Turn off keyboard illumination when computer is not used for 5 minutes
  defaults write com.apple.BezelServices kDimTime -int 300

  verbose "exiting keyboard_preferences"
  return $SUCCESS
}

# DESC: Set system preferences in the Trackpad pane
# ARGS: None
# OUTS: None
function trackpad_preferences() {
  verbose "entering trackpad_preferences"

  # Disable “natural” (Lion-style) scrolling
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

  verbose "exiting trackpad_preferences"
  return $SUCCESS
}

# DESC: Set system preferences in the Printer pane
# ARGS: None
# OUTS: None
function printer_preferences() {
  verbose "entering printer_preferences"

  # Automatically quit printer app once the print jobs complete
  defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

  verbose "exiting printer_preferences"
  return $SUCCESS
}

# DESC: Set system preferences in the Sound pane
# ARGS: None
# OUTS: None
function sound_preferences() {
  verbose "entering sound_preferences"

  # Increase sound quality for Bluetooth headphones/headsets
  defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

  verbose "exiting sound_preferences"
  return $SUCCESS
}

# DESC: Set system preferences in the Time Machine pane
# ARGS: None
# OUTS: None
function time_machine_preferences() {
  verbose "entering time_machine_preferences"

  # Prevent Time Machine from prompting to use new hard drives as backup volume
  defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

  # Disable local Time Machine backups
  # hash tmutil &> /dev/null && sudo tmutil disablelocal

  verbose "exiting time_machine_preferences"
  return $SUCCESS
}

# region app preferences

# DESC: Set preferences for Finder application
# ARGS: None
# OUTS: None
function finder_preferences() {
  verbose "entering finder_preferences"

  # Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
  defaults write com.apple.finder QuitMenuItem -bool true

  # Finder: disable window animations and Get Info animations
  defaults write com.apple.finder DisableAllAnimations -bool true

  # Set the user directory as the default location for new Finder windows
  # For Desktop, use `PfDe` and `file://${HOME}/Desktop/`
  # For other paths, use `PfLo` and `file:///full/path/here/`
  defaults write com.apple.finder NewWindowTarget -string "PfLo"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

  # Show icons for hard drives, servers, and removable media on the desktop
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

  # Finder: show hidden files by default
  defaults write com.apple.finder AppleShowAllFiles -bool true

  # Finder: show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Finder: hide status bar
  defaults write com.apple.finder ShowStatusBar -bool false

  # Finder: hide path bar
  defaults write com.apple.finder ShowPathbar -bool false

  # Display full POSIX path as Finder window title
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

  # Keep folders on top when sorting by name
  defaults write com.apple.finder _FXSortFoldersFirst -bool true

  # When performing a search, search the current folder by default
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

  # Disable the warning when changing a file extension
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

  # Enable spring loading for directories
  defaults write NSGlobalDomain com.apple.springing.enabled -bool true

  # Remove the spring loading delay for directories
  defaults write NSGlobalDomain com.apple.springing.delay -float 0

  # Avoid creating .DS_Store files on network or USB volumes
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  # Disable disk image verification
  defaults write com.apple.frameworks.diskimages skip-verify -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

  # Automatically open a new Finder window when a volume is mounted
  defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
  defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
  defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

  # Show item info near icons on the desktop and in other icon views
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
  # /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

  # Show item info on the bottom of the icons on the desktop
  /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom true" ~/Library/Preferences/com.apple.finder.plist

  # Enable snap-to-grid for icons on the desktop and in other icon views
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
  # /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

  # Increase grid spacing for icons on the desktop and in other icon views
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 64" ~/Library/Preferences/com.apple.finder.plist
  # /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 64" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 64" ~/Library/Preferences/com.apple.finder.plist

  # Increase the size of icons on the desktop and in other icon views
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 48" ~/Library/Preferences/com.apple.finder.plist
  # /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 48" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 48" ~/Library/Preferences/com.apple.finder.plist

  # Use column view in all Finder windows by default
  # Four-letter codes for view modes: `icnv`, `Nlsv`, `clmv`, `Flwv`
  defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

  # Disable the warning before emptying the Trash
  defaults write com.apple.finder WarnOnEmptyTrash -bool false

  # Enable AirDrop over Ethernet and on unsupported Macs running Lion
  defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

  # Show the ~/Library folder
  chflags nohidden ~/Library

  # Expand the following File Info panes:
  # “General”, “Open with”, and “Sharing & Permissions”
  defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

  # Expand save panel by default
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

  # Expand print panel by default
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

  # Set sidebar icon size to medium
  defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

  verbose "exiting finder_preferences"
  return $SUCCESS
}

# DESC: Set preferences for Terminal application
# ARGS: None
# OUTS: None
function terminal_preferences() {
  verbose "entering terminal_preferences"

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

  verbose "exiting terminal_preferences"
  return $SUCCESS
}

# DESC: Set preferences for iTerm application
# ARGS: None
# OUTS: None
function iterm_preferences() {
  verbose "entering iterm_preferences"

  # Don’t display the annoying prompt when quitting iTerm
  defaults write com.googlecode.iterm2 PromptOnQuit -bool false

  verbose "exiting iterm_preferences"
  return $SUCCESS
}

# DESC: Set preferences for Activity Monitor application
# ARGS: None
# OUTS: None
function activity_monitor_preferences() {
  verbose "entering activity_monitor_preferences"

  # Show the main window when launching Activity Monitor
  defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

  # Visualize CPU usage in the Activity Monitor Dock icon
  defaults write com.apple.ActivityMonitor IconType -int 5

  # Show all processes in Activity Monitor
  defaults write com.apple.ActivityMonitor ShowCategory -int 0

  # Sort Activity Monitor results by CPU usage
  defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
  defaults write com.apple.ActivityMonitor SortDirection -int 0

  verbose "exiting activity_monitor_preferences"
  return $SUCCESS
}

# DESC: Set preferences for Mail application
# ARGS: None
# OUTS: None
function mail_preferences() {
  verbose "entering mail_preferences"

  # Disable send and reply animations in Mail.app
  defaults write com.apple.mail DisableReplyAnimations -bool true
  defaults write com.apple.mail DisableSendAnimations -bool true

  # Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
  defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

  # Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app
  defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" -string "@\\U21a9"

  # Display emails in threaded mode, sorted by date (oldest at the top)
  defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
  defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes"
  defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

  # Disable inline attachments (just show the icons)
  defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

  # Disable automatic spell checking
  # defaults write com.apple.mail SpellCheckingBehavior -string "NoSpellCheckingEnabled"

  verbose "exiting mail_preferences"
  return $SUCCESS
}

# DESC: Set preferences for Messages application
# ARGS: None
# OUTS: None
function messages_preferences() {
  verbose "entering messages_preferences"

  # Disable automatic emoji substitution (i.e. use plain text smileys)
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

  # Disable smart quotes
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

  # Disable continuous spell checking
  # defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false

  verbose "exiting messages_preferences"
  return $SUCCESS
}

# DESC: Set preferences for Text Edit application
# ARGS: None
# OUTS: None
function text_edit_preferences() {
  verbose "entering text_edit_preferences"

  # Use plain text mode for new TextEdit documents
  defaults write com.apple.TextEdit RichText -int 0

  # Open and save files as UTF-8 in TextEdit
  defaults write com.apple.TextEdit PlainTextEncoding -int 4
  defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

  # open new document by default
  defaults write -g NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false

  verbose "exiting text_edit_preferences"
  return $SUCCESS
}

# DESC: Set preferences for Photos application
# ARGS: None
# OUTS: None
function photos_preferences() {
  verbose "entering photos_preferences"

  # Prevent Photos from opening automatically when devices are plugged in
  defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

  verbose "exiting photos_preferences"
  return $SUCCESS
}

# DESC: Set preferences for App Store application
# ARGS: None
# OUTS: None
function app_store_preferences() {
  verbose "entering app_store_preferences"

  # Enable the WebKit Developer Tools in the Mac App Store
  defaults write com.apple.appstore WebKitDeveloperExtras -bool true

  # Enable Debug Menu in the Mac App Store
  defaults write com.apple.appstore ShowDebugMenu -bool true

  # Enable the automatic update check
  defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

  # Check for software updates daily, not just once per week
  defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

  # Download newly available updates in background
  defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

  # Install System data files & security updates
  defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

  # Automatically download apps purchased on other Macs
  # defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

  # Turn on app auto-update
  defaults write com.apple.commerce AutoUpdate -bool true

  # Allow the App Store to reboot machine on macOS updates
  # defaults write com.apple.commerce AutoUpdateRestartRequired -bool true

  verbose "exiting app_store_preferences"
  return $SUCCESS
}

# DESC: Set preferences for Chrome application
# ARGS: None
# OUTS: None
function chrome_preferences() {
  verbose "entering chrome_preferences"

  # Disable the all too sensitive backswipe on trackpads
  # defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
  # defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false

  # Disable the all too sensitive backswipe on Magic Mouse
  # defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
  # defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false

  # Use the system-native print preview dialog
  # defaults write com.google.Chrome DisablePrintPreview -bool true
  # defaults write com.google.Chrome.canary DisablePrintPreview -bool true

  # Expand the print dialog by default
  defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
  defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

  verbose "exiting chrome_preferences"
  return $SUCCESS
}

# DESC: Set preferences for Safari application
# ARGS: None
# OUTS: None
function safari_preferences() {
  verbose "entering safari_preferences"

  # Privacy: don’t send search queries to Apple
  defaults write com.apple.Safari UniversalSearchEnabled -bool false
  defaults write com.apple.Safari SuppressSearchSuggestions -bool true

  # Press Tab to highlight each item on a web page
  defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

  # Show the full URL in the address bar (note: this still hides the scheme)
  defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

  # Set Safari’s home page to `about:blank` for faster loading
  defaults write com.apple.Safari HomePage -string "about:blank"

  # Prevent Safari from opening ‘safe’ files automatically after downloading
  defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

  # Disable hitting the Backspace key to go to the previous page in history
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool false

  # Show Safari’s bookmarks bar by default
  defaults write com.apple.Safari ShowFavoritesBar -bool true

  # Hide Safari’s sidebar in Top Sites
  defaults write com.apple.Safari ShowSidebarInTopSites -bool false

  # Disable Safari’s thumbnail cache for History and Top Sites
  defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

  # Enable Safari’s debug menu
  defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

  # Make Safari’s search banners default to Contains instead of Starts With
  defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

  # Remove useless icons from Safari’s bookmarks bar
  defaults write com.apple.Safari ProxiesInBookmarksBar "()"

  # Enable the Develop menu and the Web Inspector in Safari
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

  # Add a context menu item for showing the Web Inspector in web views
  defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

  # Enable continuous spellchecking
  defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true
  # Disable auto-correct
  defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

  # Disable AutoFill
  defaults write com.apple.Safari AutoFillFromAddressBook -bool false
  defaults write com.apple.Safari AutoFillPasswords -bool false
  defaults write com.apple.Safari AutoFillCreditCardData -bool false
  defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

  # Warn about fraudulent websites
  defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

  # Disable plug-ins
  defaults write com.apple.Safari WebKitPluginsEnabled -bool false
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false

  # Disable Java
  defaults write com.apple.Safari WebKitJavaEnabled -bool false
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false

  # Block pop-up windows
  defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

  # Enable “Do Not Track”
  defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

  # Update extensions automatically
  defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

  verbose "exiting safari_preferences"
  return $SUCCESS
}

# DESC: Set preferences for Transmission application
# ARGS: None
# OUTS: None
function transmission_preferences() {
  verbose "entering transmission_preferences"

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

  verbose "exiting transmission_preferences"
  return $SUCCESS
}

# DESC: Set preferences for Spectacle application
# ARGS: None
# OUTS: None
function spectacle_preferences() {
  verbose "entering spectacle_preferences"

  # Set up my preferred keyboard shortcuts
  cp -r "$(pwd)/tools/spectacle/spectacle.json" "${HOME}/Library/Application Support/Spectacle/Shortcuts.json" 2> /dev/null

  verbose "exiting spectacle_preferences"
  return $SUCCESS
}

# DESC: Set preferences for Archive application
# ARGS: None
# OUTS: None
function archive_preferences() {
  verbose "entering archive_preferences"

  # Move archive files to trash after expansion
  # Delete directly: "/dev/null"
  # Leave alone (default) "."
  defaults write com.apple.archiveutility dearchive-move-after -string "${HOME}/.Trash"

  verbose "exiting archive_preferences"
  return $SUCCESS
}

# endregion

# DESC: TODO
# ARGS: None
# OUTS: None
function set_preferences() {
  if [[ -n ${dry_run-} ]]; then
    verbose "skipping set_preferences"
    return $SUCCESS
  fi

  verbose "entering set_preferences"

  # Close any open System Preferences panes, to prevent them from overriding
  # settings we’re about to change
  osascript -e 'tell application "System Preferences" to quit'

  system_preferences
  disk_preferences

  finder_preferences

  general_preferences
  dock_preferences
  language_preferences
  # spotlight_preferences # TODO spotlight is NOT working
  display_preferences
  energy_preferences
  keyboard_preferences
  trackpad_preferences
  printer_preferences
  sound_preferences
  time_machine_preferences

  terminal_preferences
  iterm_preferences
  activity_monitor_preferences
  mail_preferences
  messages_preferences
  text_edit_preferences
  photos_preferences
  app_store_preferences
  chrome_preferences
  safari_preferences
  transmission_preferences
  spectacle_preferences
  archive_preferences

  for app in "${KILL_APPS[@]}"; do
    if [[ -n "${app}" ]]; then
      killall "${app}" &> /dev/null
    fi
  done

  verbose "exiting set_preferences"
  return $SUCCESS
}

# endregion

# region miscellaneous

# DESC: Miscellaneous actions/settings
# ARGS: None
# OUTS: None
function miscellaneous() {
  if [[ -n ${dry_run-} ]]; then
    verbose "skipping miscellaneous"
    return $SUCCESS
  fi

  verbose "entering miscellaneous"

  git config --global user.name "${USER_FULL_NAME}" >> "${LOG_FILE}" 2>&1 > /dev/null \
    && git config --global user.email "${USER_EMAIL}" >> "${LOG_FILE}" 2>&1 > /dev/null \
    && git config --global color.ui true >> "${LOG_FILE}" 2>&1 > /dev/null \
    && git config --global core.excludesfile "${HOME}/.gitignore_global" >> "${LOG_FILE}" 2>&1 > /dev/null \
    && git config --global credential.helper osxkeychain >> "${LOG_FILE}" 2>&1 > /dev/null

  if [[ -e "/usr/local/bin/zsh" ]]; then
    # set shell to brew zsh (preferred over bash)
    chsh -s "/usr/local/bin/zsh"
  elif [[ -e "/usr/local/bin/bash" ]]; then
    # set shell to brew bash
    chsh -s "/usr/local/bin/bash"
  fi

  verbose "exiting miscellaneous"
  return $SUCCESS
}

# endregion

# region main

# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: None
function main() {
  trap __trap_error ERR
  trap __trap_kill SIGINT SIGTERM
  trap __trap_exit EXIT

  script_init "$@"
  parse_params "$@"
  color_init

  if [[ ! -n ${dry_run-} ]]; then
    verbose "checking sudo..."

    # Ask for the administrator password upfront
    sudo -v

    # Keep-alive: update existing `sudo` time stamp until finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
  fi

  # Prompt user for inputs like name and email
  prompt_inputs

  # Create a new ssh key
  create_ssh_key

  # Create common directories
  create_directories

  # Create symlinks
  create_symlinks

  # Install homebrew, tools, and apps
  set_environment

  # Set custom system and app preferences
  set_preferences

  # Miscellaneous actions
  miscellaneous

  if [[ ! -n ${dry_run-} ]]; then
    verbose "killing sudo..."

    # Kill sudo
    sudo -K &> /dev/null
  fi

  return $SUCCESS
}

# endregion

main "$@"
exit
