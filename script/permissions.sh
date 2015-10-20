#!/usr/bin/env bash
#
# Test various functionality

# set_permissions(directory): set executable permissions to files recursively
set_permissions() {
    if [[ -n "$1" ]]; then
        if [[ -e "$1" ]]; then
            if [[ -d "$1" ]]; then
                for file in $1/*.sh; do
                    if [[ (-e "${file}") && (! -x "${file}") ]]; then
                        chmod +x "${file}"
                        echo "${file} is now executable"
                    fi
                done
                for directory in $1/*; do
                    if [[ -d "${directory}" ]]; then
                        set_permissions "${directory}"
                    fi
                done
            fi
        fi
    fi
}

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "utils.sh"

    print_section "Setting up executable file permissions"

    if [[ -n "$1" ]]; then
        local sourceDir="$(cd ../$1 && pwd)"
    else
        local sourceDir="$(cd ../os && pwd)"
    fi

    set_permissions "${sourceDir}"
    status_no_exit "Finished setting up executable file permissions"

    return "$?"
}

main "$1"
