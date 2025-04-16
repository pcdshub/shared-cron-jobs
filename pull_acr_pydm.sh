#!/usr/bin/bash
#
# Pulls recent changes to ACR's PyDM screens into the ECS deploy folder
# See /cds/group/pcds/package/epics/lcls/tools/pydm/display
# These git repos are on AFS at time of writing.
# If they move, please update their "origin" remote to the new location.
#

set -e
cd /cds/group/pcds/package/epics/lcls/tools/pydm/display
for dname in *
do
    if [ -d "$dname" ]
    then
        echo "Updating ${dname}"
        pushd "$dname"
        git pull origin master
        popd
    fi
done
