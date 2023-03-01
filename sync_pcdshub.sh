#!/bin/bash

directories=(
  /cds/group/pcds/gateway
  /cds/group/pcds/setup
  /cds/group/pcds/epics/config
)

for path in ${directories[@]}; do
  echo -e "\nSynchronizing: $path"
  cd $path || (echo "Failed: Invalid path? '$path'" && continue)
  pwd
  set -x
  git push --all pcdshub || echo "Failed: git push failure '$path'"
  set +x
done
