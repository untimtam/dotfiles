#!/usr/bin/env bash
#
# Utilities for application installation

# -----------------------------------------------------------------------------
# | Download                                                                   |
# -----------------------------------------------------------------------------

# download(output,url): download a file
download() {
    local output="$1"
    local url="$2"

    if command -v "curl" &> /dev/null; then
        curl -LsSo "${output}" "${url}" &> /dev/null
        #     │││└─ write output to file
        #     ││└─ show error messages
        #     │└─ don't show the progress meter
        #     └─ follow redirects
        return $?
    elif command -v "wget" &> /dev/null; then
        wget -qO "${output}" "${url}" &> /dev/null
        #     │└─ write output to file
        #     └─ don't show output
        return "$?"
    fi

    return 1
}

# -----------------------------------------------------------------------------
# | zip                                                                        |
# -----------------------------------------------------------------------------

# download_zip(name,url)
download_zip() {
    download "$1.zip" "$2" || return 1
    unzip "$1.zip" > /dev/null || return 1
    return 0
}

# remove_zip(name)
remove_zip() {
    rm "$1.zip" > /dev/null || return 1
    return 0
}

# -----------------------------------------------------------------------------
# | dmg                                                                        |
# -----------------------------------------------------------------------------

# download_dmg(name,url)
download_dmg() {
    download "$1.dmg" "$2" || return 1
    hdiutil mount -nobrowse "$1.dmg" > /dev/null || return 1
    return 0
}

# remove_dmg(name,path)
remove_dmg() {
    hdiutil unmount "$2" > /dev/null || return 1
    rm "$1.dmg" > /dev/null || return 1
    return 0
}
