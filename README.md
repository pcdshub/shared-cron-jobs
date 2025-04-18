# Shared Cron Jobs

## ``sync_device_config.sh``

This updates our happi config
[database](https://github.com/pcdshub/device_config) and opens a Pull Request
from deploy (prod) to master.

## ``sync_pcdshub.sh``

This pushes recent commits to a variety of repositories on
[pcdshub](https://github.com/pcdshub/), including:

* [gateway-setup](https://github.com/pcdshub/gateway-setup)
* [epics-setup](https://github.com/pcdshub/epics-setup)
* [all-deployed-iocs](https://github.com/pcdshub/all-deployed-iocs)
* [iocCommon/rhel7-x86_64](https://github.com/pcdshub/iocCommon-rhel7/)
* [iocCommon/All](https://github.com/pcdshub/iocCommon-All)
* [iocCommon/hosts](https://github.com/pcdshub/iocCommon-hosts)
* [IocManager](https://github.com/pcdshub/IocManager)
* [pvNotePad](https://github.com/pcdshub/pvNotepad)

## ``sync_pcdshub_auto_commit.sh``

This is an extension of sync_pcdshub.sh that also creates new commits.
It manages:

* [epics-config](https://github.com/pcdshub/epics-config) (which is `/cds/group/pcds/pyps/config`)


## ``sync_ui_dev.sh``

This pushes deploy backups to various ui/ux repos on pcdshub.

See https://confluence.slac.stanford.edu/pages/viewpage.action?pageId=573792593

## ``update_all_iocs.sh``

This updates [EPICS IOCs Deployed in IOC
Manager](https://confluence.slac.stanford.edu/display/PCDS/EPICS+IOCs+Deployed+in+IOC+Manager)

## ``update_hutch_python_backup.sh``

This updates our
[backup](https://github.com/pcdshub/current-hutch-python-backup) of deployed
hutch-python configurations.

## ``update_module_usage.sh``

This updates our [EPICS Module Version
Usage](https://confluence.slac.stanford.edu/display/PCDS/EPICS+Module+Version+Usage)
page.

## ``update_plc_summary.sh``

This updates [plc-summary](https://pcdshub.github.io/plc-summary/)
([source](https://github.com/pcdshub/plc-summary)).

## ``update_whatrecord_plugins.sh``

This updates the plugins that back our ECS "info" page on pswww:

* [happi](https://pswww.slac.stanford.edu/ecs/info/#/plugins/happi)
* [netconfig](https://pswww.slac.stanford.edu/ecs/info/#/plugins/netconfig)
* [epicsArch](https://pswww.slac.stanford.edu/ecs/info/#/plugins/epicsarch)
* [Gateway](https://pswww.slac.stanford.edu/ecs/info/#/gateway)

This is an "offline" view (despite the frontend being on a website) as it dumps
a JSON file that replaces the backend server by way of this
[code](https://github.com/pcdshub/whatrecord/blob/b8fcaf02e282f5c8f815e34de1f110214091d09b/whatrecord/server/server.py#L291).

# Other cron jobs referred to here

## `happi-to-confluence``: ``cron_update.sh``

This is the helper script to update our [Happi
Devices](https://confluence.slac.stanford.edu/display/PCDS/Happi+Devices) pages
by way of
[happi-to-confluence](https://github.com/pcdshub/happi-to-confluence).
