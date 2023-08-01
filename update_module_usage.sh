#!/bin/bash

source /reg/g/pcds/engineering_tools/latest-released/scripts/pcds_conda

# Location to store confluence state as we can no longer embed it directly
# into the pages:
export CONFLUENCE_STATE_PATH=$HOME/Repos/cron/state

cd /cds/home/k/klauer/Repos/module-summary || exit 1
make summary.html

cd /cds/home/k/klauer/Repos/cron || exit 1
source /cds/home/k/klauer/Repos/typhos/confluence.sh
python confluence_page_from_html.py "$HOME/Repos/module-summary/summary.html" "PCDS/EPICS Module Version Usage"
