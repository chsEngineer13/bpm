#!/bin/bash

arisDockerSetupBase=/home/kpodres/aris

if [ -z "$arisDockerComposeLog" ]; then
	source $arisDockerSetupBase/scripts/setenv.sh false
fi

source $arisDockerSetupBase/scripts/getAndEvaluateConfig.sh

echo ++++ start: docker-compose -p "$basetype" kill >> $arisDockerComposeLog 2>&1
date >> $arisDockerComposeLog
# start docker-compose up
OLDPWD=$PWD
cd $arisDockerSetupBase

docker-compose -p "$basetype" kill 2>&1 | tee -a "$arisDockerComposeLog"
cd $OLDPWD
# log end-time
echo ++++ end: docker-compose kill | tee -a "$arisDockerComposeLog"
date >> $arisDockerComposeLog

