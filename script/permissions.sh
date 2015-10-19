#!/usr/bin/env bash
#
# Test various functionality

# set_permissions(directory): set executable permissions to files recursively
set_permissions() {
    if [[ -n "$1" ]]; then
        if [[ -e "$1" ]]; then
            if [[ -d "$1" ]]; then
                for file in $1/*.sh; do
                    if [[ -e "${file}" ]]; then
                        chmod +x "${file}"
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

    local sourceDir="$(cd ../os && pwd)"
    set_permissions "${sourceDir}"
    local res="$?"
    if [[ "${res}" -eq 0 ]]; then
        echo "script success"
        return "${res}"
    else
        echo "script failure"
        return "${res}"
    fi
}

main
