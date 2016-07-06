#!/usr/bin/env bash
#
#

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_REPLACE_FAILURE=101
declare -r E_GRUB_UPDATE_FAILURE=102

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../../../script/utils.sh"

    sudo sed -i 's/quiet splash/text/g' /etc/default/grub >> "${ERROR_FILE}" 2>&1 > /dev/null
    status "Could not switch to text mode" "${E_REPLACE_FAILURE}"

    sudo update-grub >> "${ERROR_FILE}" 2>&1 > /dev/null
    status "Could not update grub" "${E_GRUB_UPDATE_FAILURE}"
}

main "$1"
