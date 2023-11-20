#!/bin/bash

cd /cds/group/pcds/shared_cron/shared-cron-jobs || exit 1

(
    /cds/group/pcds/pyps/conda/py39/envs/pcds-5.3.0/bin/whatrecord \
        iocmanager-loader \
        /cds/group/pcds/pyps/config/*/iocmanager.cfg
) > /tmp/shared-cron-all-iocs.json

./json_table.py name host port alias script < /tmp/shared-cron-all-iocs.json > /tmp/shared-cron-all-iocs.txt

# Whoever runs this needs their own PATs with write permissions
# See confluence_template.sh in this repo
# Copy to your home area with restricted read permissions and fill in username/token
# -rwx------ 1 zlentz ps-pcds 105 Nov 17 16:05 /cds/home/z/zlentz/.confluence.sh
source /cds/home/z/zlentz/.confluence.sh

# Location to store confluence state as we can no longer embed it directly
# into the pages:
export CONFLUENCE_STATE_PATH=/cds/group/pcds/shared_cron/shared-cron-jobs/state

# Pick a python env for the rest
export PCDS_CONDA_VER=5.8.0
source /cds/group/pcds/engineering_tools/latest-released/scripts/pcds_conda

./confluence_page_from_json.py \
    /tmp/shared-cron-all-iocs.json \
    'PCDS/EPICS IOCs Deployed in IOC Manager' \
    name alias host port disable script binary dir config_file \
  > /dev/null

mv /tmp/shared-cron-all-iocs.json /cds/data/iocData/.all_iocs/iocs.json
mv /tmp/shared-cron-all-iocs.txt /cds/data/iocData/.all_iocs/iocs.txt

cd /cds/data/iocData/.all_iocs/ || exit 1
git add iocs.json iocs.txt
(git commit -am "Update IOC list $(date)" || true) > /dev/null
