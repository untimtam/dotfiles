#!/usr/bin/env bash
#
# Update git remotes if necessary, and update

# -----------------------------------------------------------------------------
# | Errors                                                                     |
# -----------------------------------------------------------------------------

declare -r E_BAD_REMOTE=101
declare -r E_SET_SSH_FAILURE=102
declare -r E_UPDATE_FAILURE=103
declare -r E_UPDATE_SUBMODULE_FAILURE=104

# -----------------------------------------------------------------------------
# | Global variables                                                           |
# -----------------------------------------------------------------------------

# dotfiles repository
declare -r GITHUB_REPOSITORY="hellowor1dn/dotfiles"
declare -r DOTFILES_SSH_ORIGIN="git@github.com:${GITHUB_REPOSITORY}.git"
# declare -r DOTFILES_HTTPS_ORIGIN="https://github.com/${GITHUB_REPOSITORY}.git"

# github ssh settings
declare -r GITHUB_SET_SSH_URL="https://github.com/settings/ssh"

# -----------------------------------------------------------------------------
# | SSH                                                                        |
# -----------------------------------------------------------------------------

# setup_git_ssh_key(): set up github ssh keys if necessary
setup_git_ssh_key() {
    local sshPrivateKeyFile="id_rsa"
    local sshKeyFile="id_rsa.pub"
    local workingDirectory="$(pwd)"

    cd "${HOME}/.ssh"

    print_info "Setting up the ssh key"
    if [[ ! -r "${sshKeyFile}" ]]; then
        rm -rf "${sshKeyFile}"
        question_prompt "Email Address (email)"
        ssh-keygen -t rsa -b 4096 -C "${REPLY}"

        # add key to ssh-agent
        confirm "Add key to ssh agent?"
        if status_code && ssh-agent -s &> /dev/null; then
            ssh-add "${HOME}/.ssh/${sshPrivateKeyFile}"
        fi
    fi

    if cmd_exists "open" && cmd_exists "pbcopy"; then
        # Copy SSH key to clipboard
        cat "${sshKeyFile}" | pbcopy
        status_no_exit "Copy SSH key to clipboard"
        # Open the GitHub web page where the SSH key can be added
        open "${GITHUB_SET_SSH_URL}"
    elif cmd_exists "xclip" && cmd_exists "xdg-open"; then
        # Copy SSH key to clipboard
        cat "${sshKeyFile}" | xclip -selection clip
        status_no_exit "Copy SSH key to clipboard"
        # Open the GitHub web page where the SSH key can be added
        xdg-open "${GITHUB_SET_SSH_URL}"
    fi

    # Before proceeding, wait for ssh access
    while true; do
        # attempt to ssh to github
        ssh -T git@github.com &> /dev/null
        [[ "$?" -eq 1 ]] && break
        # sleep if not successful
        sleep 5
    done

    print_success "Finished setting up SSH key"

    cd "${workingDirectory}"
}

update_ssh() {
    ssh -T git@github.com &> /dev/null
    [[ "$?" -ne 1 ]] && setup_git_ssh_key

    return "$?"
}

# -----------------------------------------------------------------------------
# | Functions                                                                  |
# -----------------------------------------------------------------------------

# is_git_repo(): make sure git repo is initialized
is_git_repo() {
    git rev-parse &> /dev/null

    return "$?"
}

# is_dotfile_repo(): make sure we're in dotfiles git repo
is_dotfile_repo() {
    # TODO: ssh instead?
    is_git_repo && \
        [[ "$(git config --get remote.origin.url)" == "${DOTFILES_SSH_ORIGIN}" ]]

    return "$?"
}

# set_git_remote(repo): set remote origin to repo
set_git_remote() {
    git init > /dev/null \
        && git remote add origin "$1" > /dev/null

    return "$?"
}

# update_dotfiles(): update dotfiles repository
update_dotfiles() {
    if [[ ("$#" -eq 1) && ("$1" -eq 0) ]]; then
        # Update content and remove untracked files
        git fetch --all > /dev/null \
            && git reset --hard origin/master > /dev/null \
            && git clean -fd  > /dev/null
    else
        git pull origin master > /dev/null
    fi

    return "$?"
}

# update_submodules(): update git submodules
update_submodules() {
    git submodule update --init --recursive > /dev/null

    return "$?"
}

# -----------------------------------------------------------------------------
# | Main                                                                       |
# -----------------------------------------------------------------------------

main() {
    # switch path to script source
    cd "$(dirname "${BASH_SOURCE}")" \
        && source "../script/utils.sh"

    print_section "Updating from Git repository"

    # switch to base project directory
    cd ..

    # remotes
    if [[ "$1" -eq 0 ]] || ! is_git_repo; then
        set_git_remote "${DOTFILES_SSH_ORIGIN}"
        status "Set git remote to ${DOTFILES_SSH_ORIGIN}" "${E_BAD_REMOTE}"
    elif ! is_dotfile_repo; then
        print_error "Bad Git remote"
        set_git_remote "${DOTFILES_SSH_ORIGIN}"
        if status_code; then
            print_fix "Set git remote to ${DOTFILES_SSH_ORIGIN}"
        else
            errexit "Set git remote to ${DOTFILES_SSH_ORIGIN}" "${E_BAD_REMOTE}"
        fi
    fi

    # TODO: fix git setup and update
    # verify ssh key or set it up
    update_ssh
    status "Set ssh key"
    # update repo
    update_dotfiles "$1"
    status "Updated dotfiles"
    # update submodules
    update_submodules
    status "Updated dotfile dependencies"

    print_success "Finished updating from Git repository"
}

main "$1"
