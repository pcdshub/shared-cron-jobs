#!/bin/bash

SCRIPT_PATH=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

cd ${SCRIPT_PATH}
/cds/group/pcds/pyps/conda/py39/bin/python update_pswww_dashboards.py

# ECS_DASHBOARDS=/cds/group/psdm/web/pswww_01_02/html/swdoc/ecs_dashboards

# wget -O $ECS_DASHBOARDS/cryomodule.png 'http://ctl-logsrv01.pcdsn:3000/ctl/grafana/render/d/fOMF8r1nk/public-cryomodule-summary-dashboard-1?orgId=1&width=1920&height=1080&kiosk=tv' > /dev/null 2> /dev/null
# mv $ECS_DASHBOARDS/.cryomodule.png $ECS_DASHBOARDS/cryomodule.png 
