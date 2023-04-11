#!/bin/bash

cd /cds/home/k/klauer/Repos/module-summary || exit 1
make summary.html

cd /cds/home/k/klauer/Repos/cron || exit 1
source /cds/home/k/klauer/Repos/typhos/confluence.sh
python confluence_page_from_html.py "$HOME/Repos/module-summary/summary.html" "PCDS/EPICS Module Version Usage"
