#!/bin/bash

cd /cds/home/k/klauer/Repos/cron || exit 1

source pcds_conda
cd ~/Repos/whatrecord
./run_dump_plugins_only.sh
cp -f plugins-only.json.gz /cds/group/pcds/pswww/wrtest
