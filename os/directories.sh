#!/usr/bin/env bash
#
# Create some personal directories

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_MKDIR_FAILED=101

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

# TODO: set to github user if available?
declare -r USER="hellowor1dn"
declare -a DIRECTORIES=(
    "${HOME}/Desktop"

    "${HOME}/Downloads"
    "${HOME}/Downloads/torrents"

    "${HOME}/Pictures/Wallpapers"
    "${HOME}/Pictures/Screenshots"

    "${HOME}/bin"
    "${HOME}/projects"
    "${HOME}/work"
    "${HOME}/workspaces"

    "${HOME}/code"
    "${HOME}/code/Go/src/github.com/${USER}"
    # "${HOME}/code/ocaml"
)

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

# verify_directory(directory): verify directory existence
verify_directory() {
    if [[ ! -e "$1" ]]; then
        # TODO: icons?
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

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../script/utils.sh"

    print_section "Creating directories"

    for directory in "${DIRECTORIES[@]}"; do
        if [[ -n "${directory}" ]]; then
            # create directory if it doesnt already exist
            verify_directory "${directory}"
            exit_on_fail "Directory creation error or conflict"
        fi
    done

    print_success "Finished creating directories"
}

main "$1"
