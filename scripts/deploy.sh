#!/bin/bash

: ${arisDockerRegistry:=store/}
: ${arisDockerSetupBase:=/home/kpodres/aris}
: ${arisVersion:=10.0.10.0}

handleReturn(){
    local rtrn=$1
	if [[ "$rtrn" -gt 0 ]]; then
	   echo ++++ Failure: Not all container have been started successfully +++++ >> $arisDockerComposeLog 2>&1
       date >> $arisDockerComposeLog
	   echo "return code: " $rtrn
	   echo "+++ Failed (deploy.sh) +++ "
	   echo "+++ Failed (deploy.sh) +++ " >> $arisDockerComposeLog 2>&1
	   return $rtrn
	fi
    date >> $arisDockerComposeLog
	echo "+++ DONE (deploy.sh) +++ "
	echo "+++ DONE (deploy.sh) +++ " >> $arisDockerComposeLog 2>&1
}


if [ `sysctl -n vm.max_map_count` -lt 262144 ];then
    echo "******************************************************"
    echo "ERROR: The value for vm.max_map_count is too low."
    echo "       actual value :"
    echo "       " $(sysctl vm.max_map_count)
    echo "******************************************************"
    echo ""
    echo "Please change the value on your host to 262144 using this command: "
    echo "sudo sysctl -w vm.max_map_count=262144"
    echo ""
    echo "This command changes the value just for this session and is gone after a reboot."
    echo "Make it persistent in the file /etc/sysctl.conf on your host and add this line to the file: "
    echo "vm.max_map_count=262144"
    echo ""
    echo ""
    echo "The deploy ends now. Please change the value as recommended and restart the deploy again."

    exit
fi

echo "Value for vm.max_map_count is OK."
echo "       " $(sysctl vm.max_map_count)

if [ ! -d "$arisDockerSetupBase" ]; then
    mkdir -pv "$arisDockerSetupBase"
fi

echo "+++++++ setenv +++++++"
source $arisDockerSetupBase/scripts/setenv.sh true

echo "+++++++ refresh ARIS Docker +++++++"
echo "+++++++ refresh ARIS Docker +++++++" >> $arisDockerComposeLog 2>&1
source $arisDockerSetupBase/scripts/refresh.sh "${@:1}"

echo "+++++++ copy scripts to be used on the host from the admin-tools container +++++++"
echo "+++++++ copy scripts to be used on the host from the admin-tools container +++++++" >> $arisDockerComposeLog 2>&1
docker run --rm -v $arisDockerSetupBase/hostscripts/:/aris/scripts "$arisDockerRegistry"softwareag/aris-admin-tools:$arisVersion deployScripts -u $UID

echo "+++++++ check if all container up +++++++"
echo "+++++++ check if all container up +++++++" >> $arisDockerComposeLog 2>&1
source $arisDockerSetupBase/scripts/checkHealth.sh "$basetype" "$arisDockerSetupBase"

handleReturn $?
