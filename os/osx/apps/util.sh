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
        curl "${url}" -L -s -S -o "${output}" -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A" &> /dev/null
        # curl -LsSo "${output}" "${url}" &> /dev/null
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
    unzip "$1.zip" >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null || return 1
    return 0
}

# remove_zip(name)
remove_zip() {
    rm "$1.zip" >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null || return 1
    return 0
}

# -----------------------------------------------------------------------------
# | dmg                                                                        |
# -----------------------------------------------------------------------------

# download_dmg(name,url)
download_dmg() {
    download "$1.dmg" "$2" || return 1
    hdiutil mount -nobrowse "$1.dmg" >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null || return 1
    return 0
}

# remove_dmg(name,path)
remove_dmg() {
    hdiutil unmount "$2" >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null || return 1
    rm "$1.dmg" >> "${HOME}/dotfiles/dot_stderr.log" 2>&1 > /dev/null || return 1
    return 0
}
