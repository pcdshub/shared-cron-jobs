#!/bin/bash

cd /cds/group/pcds/shared_cron/current-hutch-python-backup || exit 1

bash update.sh
source "${HOME}/.pcdshub.sh"
git push origin-ssh master
