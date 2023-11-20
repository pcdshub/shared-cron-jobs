#!/bin/bash

cd /cds/group/pcds/shared_cron/shared-cron-jobs || exit 1

LOG_FN="/cds/group/pcds/shared_cron/logs/cron_${USER}_whatrecord_plugins.log"

# Tee standard output to the log file:
exec > "${LOG_FN}"
# And redirect standard error to standard output:
exec 2>&1

cd /cds/group/pcds/shared_cron/whatrecord
./run_dump_plugins_only.sh
cp -f plugins-only.json.gz /cds/group/pcds/pswww/info
