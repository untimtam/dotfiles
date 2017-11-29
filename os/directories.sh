#!/usr/bin/env bash
#
# Create some personal directories

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_INVALID_OS=101
declare -r E_MKDIR_FAILED=102
declare -r E_COMMON_FAILED=103
declare -r E_USER_FAILED=104
declare -r E_SERVER_FAILED=105

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

declare -r USER="hellowor1dn"

declare -a DIRECTORIES=(
    "${HOME}/Desktop"

    "${HOME}/Downloads"
    "${HOME}/Downloads/torrents"

    "${HOME}/Repositories"

    "${HOME}/bin"
)

declare -a USER_DIRECTORIES=(
    "${HOME}/Pictures/Wallpapers"
    "${HOME}/Pictures/Screenshots"
)

declare -a SERVER_DIRECTORIES=(
    "${HOME}/.config"
    "${HOME}/.fonts"
)

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

# verify_directory(directory): verify directory existence
verify_directory() {
    if [[ ! -e "$1" ]]; then
        # TODO: directory icons?
        mkdir -p "$1"
        status "$1 created" "${E_MKDIR_FAILED}"
        return "$?"
    elif [[ -d "$1" ]]; then
        print_success "$1 already exists"
        return 0
    else
        # file exists in place of directory
        confirm "'$1' already exists, overwrite?"
        if status_code; then
            rm -rf "$1"
            mkdir -p "$1"
            status "$1 created" "${E_MKDIR_FAILED}"
            return "$?"
        else
            print_error "A file named $1 already exists"
            return 1
        fi
    fi
}

# make_directories(directories): verify all directories in the array
make_directories() {
    declare -a directories=("${!1}")
    for directory in "${directories[@]}"; do
        if [[ -n "${directory}" ]]; then
            # create directory if it doesnt already exist
            verify_directory "${directory}"
            exit_on_fail "Directory creation error or conflict"
        fi
    done
}

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../script/utils.sh"

    print_section "Creating directories"

    make_directories DIRECTORIES[@]
    status "Finished creating common directories" "${E_COMMON_FAILED}"

    local -r OS="$(get_os)"
    if [[ "${OS}" == "osx" ]]; then
        make_directories USER_DIRECTORIES[@]
        status "Finished creating user directories" "${E_USER_FAILED}"
    elif [[ "${OS}" == "ubuntu" ]]; then
        make_directories SERVER_DIRECTORIES[@]
        status "Finished creating server directories" "${E_SERVER_FAILED}"
    else
        errexit "This OS is not supported yet!" "${E_INVALID_OS}"
    fi

    print_success "Finished creating directories"
}

main "$1"
