#!/bin/bash

source /cds/group/pcds/shared_cron/cron_venv/bin/activate

export WHATRECORD_PLUGINS="happi twincat_pytmc netconfig epicsarch"
export WHATRECORD_CACHE_PATH="/cds/data/iocData/whatrecord/cache/"
# export WHATRECORD_TWINCAT_ROOT="/cds/data/iocData/whatrecord/twincat_root/"

PYTHONPATH=/cds/group/pcds/shared_cron/whatrecord:$PYTHONPATH

python -m whatrecord.bin.main || exit 1

python -m whatrecord.bin.main server \
  --script-loader "echo []" \
  --gateway-config /cds/group/pcds/gateway/config/ \
  --dump-for-offline-usage "plugins-only.json.gz" \
  --partial-dump \
  ;
