#!/usr/bin/env bash
#
# Create symlinks to certain dotfiles or scripts

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_SYMLINK_FAILED=101
declare -r E_INVALID_OS=102

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

declare -a SYMLINK_FILES=(
    "shell/bash/bash_profile"
    "shell/bash/bashrc"

    "shell/zsh/zshrc"

    "shell/other/curlrc"
    "shell/other/wgetrc"
    "shell/other/inputrc"
    "shell/other/hushlogin"

    "tools/git/gitconfig"
    "tools/git/gitmessage"
    "tools/git/gitignore_global"

    "tools/tmux/tmux.conf"

    "tools/editor/editorconfig"
)

declare -a COMMON_BIN=(
    ""
)

declare -a USER_BIN=(
    ""
)

declare -a SERVER_BIN=(
    ""
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
        ln -fs "${sourceFile}" "${targetFile}"
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
            rm -rf "${targetFile}"
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

symlink_shell_dotfiles() {
    sourceFile=""
    targetFile=""
    for file in "${SYMLINK_FILES[@]}"; do
        if [[ -n "${file}" ]]; then
            sourceFile="$(cd .. && pwd)/${file}"
            targetFile="${HOME}/.$(printf "%s" "${file}" | sed "s/.*\/\(.*\)/\1/g")"
            # create symlink if it doesnt already exist
            verify_symlink "${sourceFile}" "${targetFile}"
            exit_on_fail "Symbolic link creation error or conflict"
        fi
    done
}

symlink_zsh_prompt() {
    # Symlink ZSH theme
    prompt_source="$(cd .. && pwd)/shell/zsh/prompt_hellowor1d_setup"
    prompt_target="$(cd .. && pwd)/shell/zsh/.zprezto/modules/prompt/functions/prompt_hellowor1d_setup"
    verify_symlink "${prompt_source}" "${prompt_target}"
    exit_on_fail "Symbolic link creation error or conflict"
}

# verify_bin_symlink(source): symlinks `source` to ~/bin
verify_bin_symlink() {
    sourceFile="$1"
    targetFile="${HOME}/bin/$(printf "%s" "$1" | sed "s/.*\/\(.*\)/\1/g")"
    verify_symlink "${sourceFile}" "${targetFile}"
}

# symlink_bin_scripts() {
#     for file in ../bin/*; do
#         verify_bin_symlink "$(cd .. && pwd)/bin/$(printf "%s" "${file}" | sed "s/.*\/\(.*\)/\1/g")"
#     done
# }

symlink_bin_scripts() {
    sourceFile=""
    targetFile=""
    for file in "${COMMON_BIN[@]}"; do
        if [[ -n "${file}" ]]; then
            sourceFile="$(cd .. && pwd)/${file}"
            targetFile="${HOME}/bin/$(printf "%s" "${file}" | sed "s/.*\/\(.*\)/\1/g")"
            # create symlink if it doesnt already exist
            verify_symlink "${sourceFile}" "${targetFile}"
            exit_on_fail "Symbolic link creation error or conflict"
        fi
    done
}

symlink_bin_user_scripts() {
    sourceFile=""
    targetFile=""
    for file in "${USER_BIN[@]}"; do
        if [[ -n "${file}" ]]; then
            sourceFile="$(cd .. && pwd)/${file}"
            targetFile="${HOME}/bin/$(printf "%s" "${file}" | sed "s/.*\/\(.*\)/\1/g")"
            # create symlink if it doesnt already exist
            verify_symlink "${sourceFile}" "${targetFile}"
            exit_on_fail "Symbolic link creation error or conflict"
        fi
    done
}

symlink_bin_server_scripts() {
    sourceFile=""
    targetFile=""
    for file in "${SERVER_BIN[@]}"; do
        if [[ -n "${file}" ]]; then
            sourceFile="$(cd .. && pwd)/${file}"
            targetFile="${HOME}/bin/$(printf "%s" "${file}" | sed "s/.*\/\(.*\)/\1/g")"
            # create symlink if it doesnt already exist
            verify_symlink "${sourceFile}" "${targetFile}"
            exit_on_fail "Symbolic link creation error or conflict"
        fi
    done
}

symlink_bootstrap_script() {
    verify_bin_symlink "$(cd .. && pwd)/script/bootstrap"
}

symlink_sublime() {
    verify_bin_symlink '/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl'
}

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../script/utils.sh"

    print_section "Creating symbolic links"

    # symlink shell dotfiles like zshrc
    symlink_shell_dotfiles
    exit_on_fail "Error symlinking shell dotfiles"

    # symlink zsh prompt
    symlink_zsh_prompt
    exit_on_fail "Error symlinking zsh prompt"

    # symlinks scripts
    symlink_bin_scripts
    exit_on_fail "Error symlinking scripts"

    # symlink bootstrap
    symlink_bootstrap_script
    exit_on_fail "Error symlinking bootstrap"

    # os specific symlinks
    local -r OS="$(get_os)"
    if [[ "${OS}" == "osx" ]]; then
        symlink_bin_user_scripts
        exit_on_fail "Error symlinking scripts"

        symlink_sublime
        exit_on_fail "Error symlinking sublime"
    elif [[ "${OS}" == "ubuntu" ]]; then
        symlink_bin_server_scripts
        exit_on_fail "Error symlinking scripts"
        # print_info "No extra symlinks on Ubuntu"
    else
        errexit "This OS is not supported yet!" "${E_INVALID_OS}"
    fi

    print_success "Finished creating symbolic links"
}

main "$1"
