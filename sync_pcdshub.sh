#!/bin/bash

# shellcheck disable=SC1091
source "${HOME}/.pcdshub.sh"
directories=(
  /cds/group/pcds/gateway
  /cds/group/pcds/setup
  /cds/data/iocData/.all_iocs
  /cds/data/iocCommon/rhel7-x86_64
  /cds/data/iocCommon/All
  /cds/data/iocCommon/hosts
)

for path in "${directories[@]}"; do
  echo -e "\nSynchronizing: $path"
  if [ ! -d "${path}" ]; then
    echo "Failed: Invalid path? '${path}'"
    continue
  fi
  cd "${path}" || continue
  pwd
  set -x
  git push --all pcdshub-https || echo "Failed: git push failure '$path'"
  set +x
done

