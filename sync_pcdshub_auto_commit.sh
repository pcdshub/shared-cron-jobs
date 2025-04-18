#!/bin/bash

# shellcheck disable=SC1091
source "${HOME}/.pcdshub.sh"
directories=(
  /cds/group/pcds/pyps/config
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
  git add -- *
  git commit -am "Automatic backup @ $(date)"
  git push origin-https master || echo "Failed: git push failure '$path'"
  set +x
done

