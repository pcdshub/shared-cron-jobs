#!/bin/bash

source /cds/group/pcds/engineering_tools/latest-released/scripts/pcds_conda

# Location to store confluence state as we can no longer embed it directly
# into the pages:
export CONFLUENCE_STATE_PATH=/cds/group/pcds/shared_cron/shared-cron-jobs/state

cd /cds/group/pcds/shared_cron/epics-module-usage-summary || exit 1
make summary.html

cd /cds/group/pcds/shared_cron/shared-cron-jobs || exit 1

# Whoever runs this needs their own PATs with write permissions
# See confluence_template.sh in this repo
# Copy to your home area with restricted read permissions and fill in username/token
# -rwx------ 1 zlentz ps-pcds 105 Nov 17 16:05 /cds/home/z/zlentz/.confluence.sh
source ~/.confluence.sh
python confluence_page_from_html.py "/cds/group/pcds/shared_cron/epics-module-usage-summary/summary.html" "PCDS/EPICS Module Version Usage"
