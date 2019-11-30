#!/bin/bash

deleteLogs=${1:-false}
arisDockerRegistry=store/
arisDockerSetupBase=/home/kpodres/aris
arisDockerLogPath=$arisDockerSetupBase/log
arisDockerDeployContentLog=$arisDockerLogPath/docker_deploy.log
arisDockerComposeLog=$arisDockerLogPath/docker_compose.log

if [ ! -d "$arisDockerLogPath" ]; then
    mkdir -p $arisDockerLogPath
elif "$deleteLogs" ; then
	echo "+++++++ delete logs +++++++"
	# clean logfiles if exist
	rm -fv $arisDockerDeployContentLog
	rm -fv $arisDockerComposeLog
fi

echo "Setup runs with environment variables set as:" >>"$arisDockerComposeLog"
echo "arisDockerRegistry 	$arisDockerRegistry" >>"$arisDockerComposeLog"
echo "arisDockerLogPath 	$arisDockerLogPath" >>"$arisDockerComposeLog"
echo "arisDockerComposeLog 	$arisDockerComposeLog" >>"$arisDockerComposeLog"

echo "Setup runs with environment variables set as:" >>"$arisDockerDeployContentLog"
echo "arisDockerRegistry 	$arisDockerRegistry" >>"$arisDockerDeployContentLog"
echo "arisDockerLogPath 	$arisDockerLogPath" >>"$arisDockerDeployContentLog"
echo "arisDockerComposeLog 	$arisDockerDeployContentLog" >>"$arisDockerDeployContentLog"