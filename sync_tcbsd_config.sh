#!/bin/bash

source /cds/group/pcds/engineering_tools/latest-released/scripts/pcds_conda
source "${HOME}/.pcdshub.sh"

bsd_config_directories=(
  /cds/group/pcds/tcbsd/twincat-bsd-ansible
)
add_directories=(
  host_vars
)

pr_title="Deploy branch status - $(date +"%B %Y")"
pr_body="** This PR was created automatically ** This PR can be used to easily see when cron-based pushes to GitHub happen, and allow us an opportunity to review changes prior to merging into master."

for path in "${bsd_config_directories[@]}"; do
  echo -e "\nSynchronizing: $path"
  cd "${path}" || (echo "Failed: Invalid path? '$path'" && continue)
  pwd
  set -x
  for dir in "${add_directories[@]}"; do
    git add "${dir}"/*
  done
  git commit -am "Automatic backup @ $(date)"
  git push origin-https deploy || echo "Failed: git push failure '${path}'"
  gh pr create -B master -H deploy -b "${pr_body}" -t "${pr_title}" || echo "PR creation failed; may already exist"
  set +x
done
