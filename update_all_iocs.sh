#!/bin/bash

cd /cds/home/k/klauer/Repos/cron

/cds/home/k/klauer/dotfiles/bin/all_iocs > /tmp/klauer-all-iocs.json
(cat /tmp/klauer-all-iocs.json |
    ./json_table.py name host port alias script ) \
    > /tmp/klauer-all-iocs.txt

# source /reg/g/pcds/pyps/conda/.tokens/typhos.sh
source /cds/home/k/klauer/Repos/typhos/confluence.sh
./confluence_page_from_json.py \
    /tmp/klauer-all-iocs.json \
    'PCDS/EPICS IOCs Deployed in IOC Manager' \
    name alias host port disable script binary dir config_file

mv /tmp/klauer-all-iocs.json /cds/data/iocData/.all_iocs/iocs.json
mv /tmp/klauer-all-iocs.txt /cds/data/iocData/.all_iocs/iocs.txt

cd /cds/data/iocData/.all_iocs/ || exit 1
git add iocs.json iocs.txt
(git commit -am "Update IOC list $(date)" || true) > /dev/null
