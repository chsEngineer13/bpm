#!/bin/bash

arisDockerSetupBase=/home/kpodres/aris

if [ -z "$arisDockerComposeLog" ]; then
	source $arisDockerSetupBase/scripts/setenv.sh false
fi

source $arisDockerSetupBase/scripts/getAndEvaluateConfig.sh

echo ++++ start: docker-compose -p "$basetype" up  ++++ | tee -a "$arisDockerComposeLog"
date >> $arisDockerComposeLog
# start docker-compose up
OLDPWD=$PWD
cd $arisDockerSetupBase

docker-compose -p "$basetype" up -d 2>&1 | tee -a "$arisDockerComposeLog"
docker-compose logs --no-color >> $arisDockerComposeLog 2>&1
cd $OLDPWD
# log end-time
echo ++++ end: docker-compose up | tee -a "$arisDockerComposeLog"
date >> $arisDockerComposeLog

