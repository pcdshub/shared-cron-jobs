#!/bin/bash

cd /cds/home/k/klauer/Repos/hutch-python-backup || exit 1

bash update.sh
git push origin master
