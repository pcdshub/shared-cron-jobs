#!/bin/bash

/cds/home/k/klauer/dotfiles/bin/all_iocs --json > /tmp/klauer-all-iocs.json
/cds/home/k/klauer/dotfiles/bin/all_iocs > /tmp/klauer-all-iocs.txt
mv /tmp/klauer-all-iocs.json /cds/data/iocData/.all_iocs/iocs.json
mv /tmp/klauer-all-iocs.txt /cds/data/iocData/.all_iocs/iocs.txt

cd /cds/data/iocData/.all_iocs/ || exit 1
git add iocs.json iocs.txt
(git commit -am "Update IOC list $(date)" || true) > /dev/null

# source /reg/g/pcds/pyps/conda/.tokens/typhos.sh
source /cds/home/k/klauer/Repos/typhos/confluence.sh

cd /cds/home/k/klauer/Repos/cron
./confluence_page_from_json.py \
    /cds/data/iocData/.all_iocs/iocs.json \
    'PCDS/Existing IOCs' \
    name alias host_port disable script binary dir config_file
