#!/bin/bash
#
# Usage: ./create-new-slac-epics-repos.sh
#  Creates new GitHub-mirrored EPICS module packages with a remote
#  named "github-slac".
#
#  Requires an SSH key that is:
#    1. Configured with GitHub
#    2. Added to your SSH agent (see ssh-add -l)
#
#  Additionally requires the "gh" command-line tool (as available in pcds-envs)
#  in your PATH.

if ! command -v gh >/dev/null; then
  echo "gh command-line tool unavailable on PATH." >/dev/stderr
  exit 1
fi

repo_list_output=$(gh repo list slac-epics -L 10000 --json name --jq ".[].name")

if [ -z "$repo_list_output" ]; then
    echo "Unable to enumerate existing repositories. Is gh configured correctly?"
    exit 1
fi

readarray -t existing_repos <<< "$repo_list_output"
declare -p existing_repos 2>/dev/null
# -> existing_repos is a bash array of all slac-epics modules

does_repo_exist() {
    local repo_to_check
    local repo
    repo_to_check=${1,,}

    for repo in "${existing_repos[@]}"; do
        if [[ "${repo,,}" = "$repo_to_check" ]]; then
            return 0
        fi
    done
    return 1
}


for gitdir in ${GIT_TOP}/package/epics/modules/*.git
do
    # Skip symlinks
    if [ -L "$gitdir" ]; then
        echo "Skipping symlink $gitdir ..."
        continue
    fi

    pushd "$gitdir" &> /dev/null || continue

    gitname=$(basename $gitdir)
    repo_name=${gitname/.git/}
    full_repo_name="slac-epics/$repo_name"

    if does_repo_exist $repo_name; then
        echo "* $(basename $gitdir) is already on slac-epics"
    else
        echo "* Creating new repository $full_repo_name for $gitdir ..."
        git config --global --add safe.directory $gitdir &> /dev/null
        (cd /tmp && \
            gh repo create --confirm --enable-issues --enable-wiki --public \
            -d "${repo_name}: Mirror for $gitdir" $full_repo_name \
        ) || echo "gh repo create failed; maybe repository already exists?"
        git remote add github-slac git@github.com:$full_repo_name
        git remote add github-slac-https https://github.com/$full_repo_name
        # git push --mirror github-slac
    fi
    popd &> /dev/null || exit 1
done
