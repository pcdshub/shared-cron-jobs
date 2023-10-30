#!/bin/bash

cd /cds/home/k/klauer/Repos/cron || exit 1

LOG_FN="$HOME/Repos/cron/cron_${USER}_whatrecord_plugins.log"

# Tee standard output to the log file:
exec > "${LOG_FN}"
# And redirect standard error to standard output:
exec 2>&1

cd ~/Repos/whatrecord
./run_dump_plugins_only.sh
cp -f plugins-only.json.gz /cds/group/pcds/pswww/info
