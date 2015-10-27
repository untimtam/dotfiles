#!/usr/bin/env bash
#
# Utilities for application installation

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

if [[ -z "${ERROR_FILE}" ]]; then
    # only declare if main utils not sourced
    declare -r ERROR_FILE="${HOME}/dotfiles/dot_error.log"
fi
declare -r CURL_USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A"

# -----------------------------------------------------------------------------
# | Download                                                                   |
# -----------------------------------------------------------------------------

# download(output,url): download a file
# curl -LsSk -o "${output}" -A "${CURL_USER_AGENT}" "${url}" >> "${ERROR_FILE}" 2>&1 > /dev/null
#       ││││  │              └─ user agent: disguies curl as a browser
#       ││││  └─ output: write output to file
#       │││└─ insecure: dont check ssl certificate
#       ││└─ error: show error messages upon failure
#       │└─ silent: don't show the progress meter
#       └─ location: follow redirects
download() {
    local output="$1"
    local url="$2"

    if command -v "curl" &> /dev/null; then
        # try normal download
        curl -LsS -o "${output}" -A "${CURL_USER_AGENT}" "${url}" >> "${ERROR_FILE}" 2>&1 > /dev/null
        if [[ "$?" -ne 0 ]]; then
            # if download fails, try without ssl certificates
            curl -LsSk -o "${output}" -A "${CURL_USER_AGENT}" "${url}" >> "${ERROR_FILE}" 2>&1 > /dev/null
            return "$?"
        fi
        return 0
    elif command -v "wget" &> /dev/null; then
        wget -qO "${output}" "${url}" >> "${ERROR_FILE}" 2>&1 > /dev/null
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
    unzip "$1.zip" >> "${ERROR_FILE}" 2>&1 > /dev/null || return 1
    return 0
}

# remove_zip(name)
remove_zip() {
    rm "$1.zip" >> "${ERROR_FILE}" 2>&1 > /dev/null || return 1
    return 0
}

# -----------------------------------------------------------------------------
# | dmg                                                                        |
# -----------------------------------------------------------------------------

# download_dmg(name,url)
download_dmg() {
    download "$1.dmg" "$2" || return 1
    hdiutil mount -nobrowse "$1.dmg" >> "${ERROR_FILE}" 2>&1 > /dev/null || return 1
    return 0
}

# remove_dmg(name,path)
remove_dmg() {
    hdiutil unmount "$2" >> "${ERROR_FILE}" 2>&1 > /dev/null || return 1
    rm "$1.dmg" >> "${ERROR_FILE}" 2>&1 > /dev/null || return 1
    return 0
}
