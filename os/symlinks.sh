#!/usr/bin/env bash
#
# Create symlinks to certain dotfiles or scripts

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_SYMLINK_FAILED=101

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

# declare -r TMPHOME="${HOME}/tmp"
declare -a SYMLINK_FILES=(
    "shell/bash/bash_profile"
    "shell/bash/bashrc"

    "shell/zsh/zshrc"

    "shell/other/curlrc"
    "shell/other/wgetrc"
    "shell/other/inputrc"
    "shell/other/screenrc"
    "shell/other/hushlogin"

    "tools/tmux/tmux.conf"

    "tools/git/gitattributes"
    "tools/git/gitconfig"
    "tools/git/gitignore_global"

    "tools/vim/vim"
    "tools/vim/vimrc"
    "tools/vim/gvimrc"

    "tools/editor/editorconfig"
)

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

# verify_symlink(source, target):
verify_symlink() {
    sourceFile="$1"
    targetFile="$2"

    if [[ ! -e "${targetFile}" ]]; then
        # create new symbolic link
        # TODO: ln -fs "${sourceFile}" "${targetFile}"?
        ln -s "${sourceFile}" "${targetFile}"
        status "${targetFile} → ${sourceFile}" "${E_SYMLINK_FAILED}"
        return "$?"
    elif [[ "$(readlink "${targetFile}")" == "${sourceFile}" ]]; then
        # this symlink already exists
        print_success "${targetFile} → ${sourceFile} already exists"
        return 0
    else
        # file exists but not symlink
        confirm "'${targetFile}' already exists, overwrite?"
        if status_code; then
            # overwrite
            # TODO: rm -rf "${targetFile}"?
            ln -fs "${sourceFile}" "${targetFile}"
            status "overwrite ${targetFile} → ${sourceFile}" "${E_SYMLINK_FAILED}"
            return "$?"
        else
            # dont symlink
            print_error "${targetFile} → ${sourceFile} not overwritten"
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

    print_section "Creating symbolic links"

    local sourceFile=""
    local targetFile=""
    for file in ${SYMLINK_FILES[@]}; do
        sourceFile="$(cd .. && pwd)/${file}"
        targetFile="${HOME}/.$(printf "%s" "${file}" | sed "s/.*\/\(.*\)/\1/g")"

        if [[ -n "${file}" ]]; then
            # create symlink if it doesnt already exist
            verify_symlink "${sourceFile}" "${targetFile}"
            exit_on_fail "Symbolic link creation error or conflict"
        fi
    done

    print_success "Finished creating symbolic links"
}

main "$1"
