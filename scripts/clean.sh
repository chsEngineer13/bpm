#!/bin/bash
: ${arisDockerRegistry:=store/}
: ${arisDockerSetupBase:=/home/kpodres/aris}

if [ -z "$arisDockerComposeLog" ]; then
	source $arisDockerSetupBase/scripts/setenv.sh false
fi

source $arisDockerSetupBase/scripts/getAndEvaluateConfig.sh

echo ++++ start: clean system  | tee -a "$arisDockerComposeLog"
date >> $arisDockerComposeLog

source $arisDockerSetupBase/scripts/teardown.sh

removeRemainingContainers(){
	local remainingContainer=($(docker container ps -a -q -f label=com.softwareag.product=ARIS))
	if [ "${#remainingContainer[@]}" -gt 0 ]; then
		echo ++++ docker container stop ++++ | tee -a "$arisDockerComposeLog"
		docker container stop ${remainingContainer[@]} >> $arisDockerComposeLog 2>&1
		echo ++++ docker remove ARIS containers  >> $arisDockerComposeLog 2>&1
		docker container rm -f ${remainingContainer[@]} >> $arisDockerComposeLog 2>&1
	fi
}

removeRemainingImages(){
	remainingImages=($(docker image ls -q -f label=com.softwareag.product=ARIS))
	if [ "${#remainingImages[@]}" -gt 0 ]; then
		echo ++++ docker remove ARIS images ++++ | tee -a "$arisDockerComposeLog"
		docker image rm -f ${remainingImages[@]} >> $arisDockerComposeLog 2>&1
	fi
}

removeRemainingVolumes(){
	remainingVolumes=($(docker volume ls -q -f label=com.softwareag.volume.type))
	if [ "${#remainingVolumes[@]}" -gt 0 ] && [[ $rmVolumesflag == "y" ]]; then
		echo ++++ docker remove ARIS volumes ++++ | tee -a "$arisDockerComposeLog"
		docker volume rm -f ${remainingVolumes[@]} >> $arisDockerComposeLog 2>&1
	fi
}

listRemainingDockerContent(){
	echo ++++ list remaining container, images and volumes +++++ >> $arisDockerComposeLog 2>&1
	docker container ps  >> $arisDockerComposeLog 2>&1
	docker image ls  >> $arisDockerComposeLog 2>&1
	docker volume ls  >> $arisDockerComposeLog 2>&1
}

removeRemainingContainers;
removeRemainingImages;
removeRemainingVolumes;
listRemainingDockerContent;

echo ++++ end: clean system ++++ | tee -a "$arisDockerComposeLog"
date >> $arisDockerComposeLog