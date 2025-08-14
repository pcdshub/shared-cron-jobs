#!/bin/bash

set -e

# Location to store confluence state as we can no longer embed it directly
# into the pages:
export CONFLUENCE_STATE_PATH=/cds/group/pcds/shared_cron/shared-cron-jobs/state

cd /cds/group/pcds/shared_cron/iocmanager
# shellcheck disable=SC1091
source ./scripts/default_env
echo "generating table..."
"${IOCMAN_PY_BIN}"/python -m iocmanager.scripts.survey_os --confluence-table > rocky9.html

cd /cds/group/pcds/shared_cron/shared-cron-jobs

# Whoever runs this needs their own PATs with write permissions
# See confluence_template.sh in this repo
# Copy to your home area with restricted read permissions and fill in username/token
# -rwx------ 1 zlentz ps-pcds 105 Nov 17 16:05 /cds/home/z/zlentz/.confluence.sh
# shellcheck disable=SC1090
source ~/.confluence.sh
echo "uploading table if new..."
"${IOCMAN_PY_BIN}"/python confluence_page_from_html.py "/cds/group/pcds/shared_cron/iocmanager/rocky9.html" "PCDS/Rocky9 EPICS IOC Migration Live Info"
echo "done"
