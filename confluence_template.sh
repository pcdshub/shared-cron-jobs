#!/bin/bash
# Use this file to authenticate confluence-writing cron jobs.
# You can get a confluence PAT in the confluence settings.
# For the user who is to run the cron jobs:
# 1. Copy this to your home area as ~/.confluence.sh
# 2. Change the write permissions so that nobody but you can rwx it:
#    chmod 700 ~/.confluence.sh
# 3. Replace the information as appropriate.
export CONFLUENCE_USER="your-username-here"
export CONFLUENCE_TOKEN="write-token-goes-here"
