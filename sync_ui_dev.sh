#!/bin/bash

# shellcheck disable=SC1091
source /cds/group/pcds/engineering_tools/latest-released/scripts/pcds_conda
source "${HOME}/.pcdshub.sh"

ui_dev_directories=(
  /cds/group/pcds/epics-dev/screens/edm/common/current
  /cds/group/pcds/epics-dev/screens/edm/cxi/current
  /cds/group/pcds/epics-dev/screens/edm/det/current
  /cds/group/pcds/epics-dev/screens/edm/hxray/current
  /cds/group/pcds/epics-dev/screens/edm/las/current
  /cds/group/pcds/epics-dev/screens/edm/mec/current
  /cds/group/pcds/epics-dev/screens/edm/mfx/current
  /cds/group/pcds/epics-dev/screens/edm/xcs/current
  /cds/group/pcds/epics-dev/screens/edm/xpp/current
  /cds/group/pcds/epics-dev/screens/pydm/eps
  /cds/group/pcds/epics-dev/screens/pydm/kfe
  /cds/group/pcds/epics-dev/screens/pydm/lfe
  /cds/group/pcds/epics-dev/screens/pydm/mec
  /cds/group/pcds/epics-dev/screens/pydm/mirrors
  /cds/group/pcds/epics-dev/screens/pydm/rix
  /cds/group/pcds/epics-dev/screens/pydm/scripts
  /cds/group/pcds/epics-dev/screens/pydm/sds
  /cds/group/pcds/epics-dev/screens/pydm/tmo
  /cds/group/pcds/epics-dev/screens/pydm/txi
  /cds/group/pcds/epics-dev/screens/pydm/ued
  /cds/group/pcds/epics-dev/screens/pydm/vacuum
  /cds/group/pcds/epics-dev/screens/pydm/xcs
)

pr_title="Deploy branch status - $(date +"%B %Y")"
pr_body="** This PR was created automatically ** This PR can be used to easily see when cron-based pushes to GitHub happen, and allow us an opportunity to review changes prior to merging into master."

for path in "${ui_dev_directories[@]}"; do
  echo -e "\nSynchronizing: $path"
  cd "${path}" || echo "Failed: Invalid path? '${path}'" && continue
  pwd
  set -x
  git add -- *
  git commit -am "Automatic backup @ $(date)"
  git push origin-https deploy || echo "Failed: git push failure '$path'"
  gh pr create -B master -H deploy -b "$pr_body" -t "$pr_title" || echo "PR creation failed; may already exist"
  set +x
done
