#!/bin/bash

source /cds/group/pcds/engineering_tools/latest-released/scripts/pcds_conda

cd /cds/group/pcds/shared_cron/plc-summary/docs || exit 1

set -xe

git checkout master
make html
git add source/*.rst
git commit -am "Updated projects on $(date)"

cd ../
make gh-pages

set +xe
git push origin master gh-pages
git checkout master
