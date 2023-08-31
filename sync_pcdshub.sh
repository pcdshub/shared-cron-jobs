#!/bin/bash

directories=(
  /cds/group/pcds/gateway
  /cds/group/pcds/setup
  /cds/group/pcds/epics/config
  /cds/data/iocData/.all_iocs
  /cds/data/iocCommon/rhel7-x86_64
  /cds/data/iocCommon/All
  /cds/data/iocCommon/hosts
  /afs/slac.stanford.edu/g/cd/swe/git/repos/slac/iocmgmt/IocManager.git
)

for path in ${directories[@]}; do
  echo -e "\nSynchronizing: $path"
  cd $path || (echo "Failed: Invalid path? '$path'" && continue)
  pwd
  set -x
  git push --all pcdshub || echo "Failed: git push failure '$path'"
  set +x
done


directories=(
  /cds/home/k/klauer/Repos/eco_tools
)

for path in ${directories[@]}; do
  echo -e "\nSynchronizing: $path"
  cd $path || (echo "Failed: Invalid path? '$path'" && continue)
  pwd
  set -x
  git fetch --tags origin || echo "Failed: git fetch failure '$path'"
  git pull origin trunk:master trunk:trunk || echo "Failed: git pull failure '$path'"
  git push --all pcdshub || echo "Failed: git push failure '$path'"
  set +x
done
