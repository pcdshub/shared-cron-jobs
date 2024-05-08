#!/bin/bash

source /cds/group/pcds/engineering_tools/latest-released/scripts/pcds_conda
source "${HOME}/.pcdshub.sh"

bsd_config_directories=(
  /cds/group/pcds/pyps/apps/atef/config
)

pr_title="Deploy branch status - $(date +"%B %Y")"
pr_body="** This PR was created automatically ** This PR can be used to easily see when cron-based pushes to GitHub happen, and allow us an opportunity to review changes prior to merging into master."

for path in "${bsd_config_directories[@]}"; do
  echo -e "\nSynchronizing: $path"
  cd "${path}" || (echo "Failed: Invalid path? '$path'" && continue)
  pwd
  set -x
  git add .
  git commit -am "Automatic backup @ $(date)"
  git push origin-https deploy || echo "Failed: git push failure '${path}'"
  gh pr create -B master -H deploy -b "${pr_body}" -t "${pr_title}" || echo "PR creation failed; may already exist"
  set +x
done
