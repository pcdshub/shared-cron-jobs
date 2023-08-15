#!/bin/bash

source /reg/g/pcds/engineering_tools/latest-released/scripts/pcds_conda

device_config_directories=(
  /cds/group/pcds/pyps/apps/hutch-python/device_config
)

pr_title="Deploy branch status - $(date +"%B %Y")"
pr_body="** This PR was created automatically ** This PR can be used to easily see when cron-based pushes to GitHub happen, and allow us an opportunity to review changes prior to merging into master."

for path in ${device_config_directories[@]}; do
  echo -e "\nSynchronizing: $path"
  cd $path || (echo "Failed: Invalid path? '$path'" && continue)
  pwd
  set -x
  git commit -am "Automatic backup @ $(date)"
  git push origin-ssh deploy || echo "Failed: git push failure '$path'"
  gh pr create -B master -H deploy -b "$pr_body" -t "$pr_title" || echo "PR creation failed; may already exist"
  set +x
done
