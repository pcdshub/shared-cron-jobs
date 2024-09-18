#!/bin/bash
# Use this file to authenticate slac-epics-pushing cron jobs.
# You can get a github fine-grained PAT in the github settings.
#
# You need the following "repository permissions" for "all repositories"
# in the slac-epics org. NOTE: not "organization permissions"!
# 1. Read access to metadata
# 2. Write access to contents
# 3. Write access to administration
#
# For the user who is to run the cron jobs:
# 1. Copy this to your home area as ~/.slac-epics.sh
# 2. Change the write permissions so that nobody but you can rwx it:
#    chmod 700 ~/.slac-epics.sh
# 3. Replace the information as appropriate.
# 4. Set your git config to use the env var to authenticate https pushes.
#    Make sure to include your username in this command as appropriate:
#    git config --global credential.helper '!f() { echo username=yourghusername; echo "password=$GH_TOKEN"; };f'
export GH_TOKEN="write-token-goes-here"
