#!/bin/bash

echo "** Updating EPICS modules **"

echo "** Updating kerberos/afs tokens..."
source $HOME/dotfiles/bin/tokens

echo "** Using the PCDS conda env..."
source /cds/group/pcds/engineering_tools/latest-released/scripts/pcds_conda

cd /afs/slac/g/cd/swe/git/repos/package/epics/modules

echo "** Working directory:"
pwd

echo "** Creating new repositories, if necessary:"
./create-new-slac-epics-repos.sh

echo "** Synchronizing existing repositories:"
./push2slac-epics-via-ssh.sh

echo "Done."
