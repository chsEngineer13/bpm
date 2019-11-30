#!/bin/bash

: ${arisDockerRegistry:=store/}
: ${arisDockerSetupBase:=/home/kpodres/aris}

if [ -z "$arisDockerComposeLog" ]; then
	source $arisDockerSetupBase/scripts/setenv.sh false
fi

# workaround for docker network bug
source $arisDockerSetupBase/scripts/cleannetwork.sh

source $arisDockerSetupBase/scripts/getAndEvaluateConfig.sh "${@:1}"

# these variables are replaced by build process
version=10.0.10.0
codeline=//ALL/rel/10.0/10.0.10

composeDir=$arisDockerSetupBase/compose

echo "+++++ Start aris docker refresh +++++" | tee -a "$arisDockerComposeLog"
echo "++++++ create compose ++++++" | tee -a "$arisDockerComposeLog"
# log start-time
date >> $arisDockerComposeLog
echo Version: $version >> $arisDockerComposeLog 2>&1
echo Codeline: //ALL/rel/10.0/10.0.10 >> $arisDockerComposeLog 2>&1

#Create docker compose file for selected Scenario
source $composeDir/createComposeForParameter.sh >>"$arisDockerComposeLog" 2>&1

source $arisDockerSetupBase/scripts/clean.sh

source $arisDockerSetupBase/scripts/start.sh

echo "+++++ End aris docker refresh +++++" | tee -a "$arisDockerComposeLog"

