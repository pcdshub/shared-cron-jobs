#!/bin/bash
#
# Usage: ./push2slac-epics-via-pat.sh
#  Updates all GitHub-mirrored EPICS module packages with a remote
#  named "github-slac".
#
#  Based on the previous push2slac-epics-via-ssh.sh script
#
#  Requires a fine-grained PAT with the following permissions:
#    1. Metadata (read)
#    2. Content (write)

SLEEP_PERIOD=2

if [ -z "$GIT_TOP" ]; then
  echo "GIT_TOP unset." 1>&2
  exit 1
fi

get_bad_commits() {
  # List all bad commits in the repository: that is, those without author names and e-mails
  git log --all --oneline --pretty=tformat:"%H %an:%aE" | \
    sed -E -e '/\S* \S+:\S+/d' -e 's/(\S+) .*$/--no-contains \1/'
}

get_things_to_push() {
  bad_commits=$(get_bad_commits | tr '\n' ' ')
  [ -n "${bad_commits}" ] && echo "Skipping bad commits: ${bad_commits}" 1>&2
  # Branches without bad commits:
  git for-each-ref --format='%(refname:short)' refs/heads/ ${bad_commits}
  # Tags without bad commits:
  git tag ${bad_commits}
}

for gitdir in ${GIT_TOP}/package/epics/modules/*.git ${GIT_TOP}/package/epics/base/base.git
do
    pushd "$gitdir" &> /dev/null || continue
    git config --global --add safe.directory $(pwd -P) &> /dev/null
    (git remote get-url --push github-slac-https &> /dev/null) && (
        echo "* Updating $gitdir ..."
        # git push --dry-run --mirror github-slac-https
        to_push=$(get_things_to_push)
        if [ -z "$to_push" ]; then
          echo "Nothing to push. All refs have invalid commits?"
          continue
        fi
        git push github-slac-https ${to_push} || sleep 5
        # This may take a while, but we often get rate-limited as we hit GitHub
        # quite a bit here:
        sleep "${SLEEP_PERIOD}"
    ) || (
        echo "* $(basename $gitdir) is not on slac-epics"
    )
    popd &> /dev/null || exit 1
done
