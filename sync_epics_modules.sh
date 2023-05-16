#!/bin/bash

cd /afs/slac/g/cd/swe/git/repos/package/epics/modules

./create-new-slac-epics-repos.sh
./push2slac-epics-via-ssh.sh
