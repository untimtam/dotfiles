#!/usr/bin/env bash
#
# General utils for dotfiles

# -----------------------------------------------------------------------------
# | Print                                                                      |
# -----------------------------------------------------------------------------

# Colors:
# RESET    0
# BLACK   30, 90
# RED     31, 91
# GREEN   32, 92
# YELLOW  33, 93
# BLUE    34, 94
# MAGENTA 35, 95
# CYAN    36, 96
# WHITE   37, 97

print_in_black() {
    printf "\e[0;30m$1\e[0m"
}

print_in_red() {
    printf "\e[0;31m$1\e[0m"
}

print_in_green() {
    printf "\e[0;32m$1\e[0m"
}

print_in_yellow() {
    printf "\e[0;33m$1\e[0m"
}

print_in_blue() {
    printf "\e[0;34m$1\e[0m"
}

print_in_purple() {
    printf "\e[0;35m$1\e[0m"
}

print_in_cyan() {
    printf "\e[0;36m$1\e[0m"
}

print_in_white() {
    printf "\e[0;37m$1\e[0m"
}

print_section() {
    print_in_blue "\n $1\n\n"
}

print_info() {
    print_in_blue "  [ ! ] $1\n"
}

print_success() {
    print_in_green "  [ ✔ ] $1\n"
}

print_error() {
    print_in_red "  [ ✖ ] $1\n"
}

print_question() {
    print_in_yellow "  [ ? ] $1"
}

print_fix() {
    print_in_cyan "   [ + ] $1\n"
}

print_separator_large() {
    print_in_purple "\n  ---\n\n"
}

print_separator() {
    print_in_purple "  ---\n"
}

# print_status(status, message, err_code, [no_exit]): validate and print the status
print_status() {
    if [[ "$1" -ne 0 ]]; then
        # failed
        if [[ ("$#" -eq 4) && "$4" -eq 0 ]]; then
            # no exit
            print_error "$2"
        else
            # exit on failure
            errexit "$2" "$3"
        fi
    else
        # passed
        print_success "$2"
    fi
    # propagate status
    return "$1"
}

# status(message, err_code, [no_exit]): print the status of the last command
status() {
    # TODO: test thoroughly
    local status_code="$?"
    if [[ "$#" -eq 3 ]]; then
        print_status "${status_code}" "$1" "$2" "$3"
    else
        print_status "${status_code}" "$1" "$2"
    fi

    # propagate status
    return "${status_code}"
}

# status_no_exit(message): print success or failure message
status_no_exit() {
    local status_code="$?"
    # err_code doesnt matter since an error will never be thrown
    print_status "${status_code}" "$1" 1 0

    # propagate status
    return "${status_code}"
}

# status_code(): return status_code of last command
status_code() {
    [[ "$?" -eq 0 ]] \
        && return 0 \
        || return 1
}

# -----------------------------------------------------------------------------
# | Prompt                                                                     |
# -----------------------------------------------------------------------------

# question_prompt(question): prompt the user for input, read answer from "${REPLY}"
question_prompt() {
    print_question "$1 : "
    read
}

# question_result(): get user reply (could also just read from REPLY)
# question_result() {
#     printf "${REPLY}"
# }

# confirm_prompt(question): prompt the user for confirmation
confirm_prompt() {
    print_question "$1 (y/n) "
    read -n 1
    printf "\n"
}

# confirm(question): prompt for confirmation and return bash friendly result
confirm() {
    confirm_prompt "$1"
    if [[ "${REPLY}" =~ ^[YyNn]$ ]]; then
        if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
            return 0
        else
            return 1
        fi
    else
        confirm "$1"
    fi
}

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

# err([err_code], message): print out error messages
# https://google-styleguide.googlecode.com/svn/trunk/shell.xml#STDOUT_vs_STDERR
# usage: err "Unable to do something"
#        exit "$(E_DID_NOTHING)"
err() {
  print_in_red "[ ✖ ] [$(date +'%Y-%m-%d %H:%M:%S%z')]: $@ \n" >&2
}

# errexit(message, err_code): print out error message and exit
errexit() {
    err "$1"
    exit "$2"
}

# exit_on_fail(message):
exit_on_fail() {
    local stat="$?"
    if [[ "${stat}" -ne 0 ]]; then
        errexit "$1" "$stat"
    fi
}

# -----------------------------------------------------------------------------
# | System                                                                     |
# -----------------------------------------------------------------------------

request_sudo() {
    print_in_yellow "  [ ? ] $1"
    print_in_yellow "\n  [ ? ] Sudo: \n  "
    # Ask for the administrator password upfront
    sudo -v &> /dev/null
    # Update existing `sudo` time stamp until this script has finished
    # https://gist.github.com/cowboy/3118588
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done &> /dev/null &
}

kill_sudo() {
    sudo -K &> /dev/null
}

# cmd_exists(command): verify that a command exists
cmd_exists() {
    command -v "$1" &> /dev/null
    return $?
}

# get_os(): get current os
get_os() {
    declare -r OS_NAME="$(uname -s)"
    local os=""

    if [[ "${OS_NAME}" == "Darwin" ]]; then
        os="osx"
    elif [[ ("${OS_NAME}" == "Linux") && (-e "/etc/lsb-release") ]]; then
        os="ubuntu"
    else
        os="${OS_NAME}"
    fi

    printf "%s" "${os}"
}

# symlink(source, target)
symlink() {
    ln -s "$1" "$2"
}
