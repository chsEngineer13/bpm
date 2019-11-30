#!/bin/bash

: ${arisDockerRegistry:=store/}
: ${arisDockerSetupBase:=/home/kpodres/aris}

source $arisDockerSetupBase/scripts/getAndEvaluateConfig.sh "${@:1}"

#Needed as env variable for compose, to replace the var in template of LB
export HOSTNAME="$HOSTNAME"

createAppTypeLst(){
	arisbase=zoo,elastic,cs,umcadmin,adsadmin,accserver,lb
	internaldb=pg
	arisconnect=abs,apg,dashboarding,octo,cop,ecp,simu
	api=api,kibana,cop,ecp
	arcm=abs,arcm
	hds=cdf,hds

	applist=$arisbase
	case "$basetype" in
	   "connect")
			applist="$applist","$arisconnect"
			if [ "$arcmflag" == y ]; then
				applist="$applist","arcm";
			fi
			if [ "$hdsflag" == y ]; then
				applist="$applist","$hds";
			fi
			if [ "$mcpflag" == y ]; then
				applist="$applist","mcp";
			fi
		;;
	   "api")
			applist="$applist","$api"
		;;
	   "arcm")
			applist="$applist","$arcm"
		;;
	esac
	if [ "$dbflag" == y ]; then
		applist="$applist","$internaldb";
	fi
}
createScenarioStr(){
	scenario=""
	case "$basetype" in
	   "connect")
			scenario="ARIS connect server"
			if [ "$arcmflag" == y ]; then
				scenario="$scenario"", with arcm addon"
			fi
			if [ "$hdsflag" == y ]; then
				scenario="${scenario}, with hds addon"
			fi
			if [ "$mcpflag" == y ]; then
				scenario="${scenario}, with mcp addon"
			fi
		;;
	   "api")
			scenario="API server "
		;;
	   "arcm")
			scenario="ARCM server "
		;;
	esac
	if [ "$dbflag" == y ]; then
		scenario="${scenario}, with internal DB"
	fi
}
createAppTypeLst
createScenarioStr
echo $applist
echo $scenario
targetpath=$arisDockerSetupBase
scriptdir=$arisDockerSetupBase/compose
composefile="docker-compose"

#Switch to composedir to use .env, otherwise it would not work
cd $scriptdir
echo "Create compose file for $scenario"
echo "with createCompose.sh $composefile $applist $targetpath"
source createCompose.sh "$composefile" "$applist" "$targetpath"
cd $OLDPWD