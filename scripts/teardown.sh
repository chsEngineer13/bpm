#!/bin/bash

arisDockerSetupBase=/home/kpodres/aris

if [ -z "$arisDockerComposeLog" ]; then
	source $arisDockerSetupBase/scripts/setenv.sh false
fi

source $arisDockerSetupBase/scripts/getAndEvaluateConfig.sh

OLDPWD=$PWD
cd $arisDockerSetupBase
# -v to delete all volumes created by this compose project, remove to test update ;-)

if [[ $rmVolumesflag == "y" ]]; then
    echo ++++ start: docker-compose -p "$basetype" -f docker-compose.yml down -v --rmi all ++++ 2>&1 | tee -a "$arisDockerComposeLog"
    date >> $arisDockerComposeLog
    docker-compose -p "$basetype" -f docker-compose.yml down -v --rmi all 2>&1 | tee -a "$arisDockerComposeLog"
else
    echo ++++ start: docker-compose -p "$basetype" -f docker-compose.yml down --rmi all  ++++ 2>&1 | tee -a "$arisDockerComposeLog"
    date >> $arisDockerComposeLog
    docker-compose -p "$basetype" -f docker-compose.yml down --rmi all 2>&1 | tee -a "$arisDockerComposeLog"
fi

#switch back to previous dir
cd $OLDPWD

echo ++++ end: tear down | tee -a "$arisDockerComposeLog"
date >> $arisDockerComposeLog

