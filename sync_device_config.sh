#!/bin/bash

device_config_directories=(
  /cds/group/pcds/pyps/apps/hutch-python/device_config
)

for path in ${device_config_directories[@]}; do
  echo -e "\nSynchronizing: $path"
  cd $path || (echo "Failed: Invalid path? '$path'" && continue)
  pwd
  set -x
  git commit -am "Automatic backup @ $(date)"
  git push origin-ssh deploy || echo "Failed: git push failure '$path'"
  set +x
done
