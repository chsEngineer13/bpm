#!/bin/bash

: ${arisDockerRegistry:=store/}
: ${arisDockerSetupBase:=/home/kpodres/aris}

#This export is needed as environment variable for replacement in compose templates
export arisDockerRegistry

selectedParameterFile=$arisDockerSetupBase/selected.properties
basetypeCount=0
: ${alwaysYes:=n}
: ${basetype:=${basetype:-}}
checkbase() {
     #echo "checkbase"
     if [[ -n "$basetype" ]] && [[ $basetypeCount -gt 0 ]] ; then
         echo "Cannot install multiple products, choose either connect, api, or arcm"
         exit 5
     else
        let basetypeCount++ ;
     fi
}
setDefaultsForUnset(){
    #echo "setDefaultsForUnset"
	: ${basetype:=${basetype:-connect}} #Possible values connect, api or arcm
	: ${dbflag:=${dbflag:-y}} #Default with internal DB, switch to n for external DB
	: ${arcmflag:=${arcmflag:-n}} #Default without arcm as add on to connect, otherwise it will be ignored
	: ${hdsflag:=${hdsflag:-n}} #Default without hds as add on to connect, otherwise it will be ignored
	: ${mcpflag:=${mcpflag:-n}} #Default without hds as add on to connect, otherwise it will be ignored
	: ${rmVolumesflag:=${rmVolumesflag:-n}} #Default is set to do not remove docker volumes

	if [[ $basetype != "connect" ]] && [[ "$arcmflag" == "y" ]]; then
	  echo "ARCM add-on can only be installed with product connect"
	  exit 6
	fi
	if [[ $basetype != "connect" ]] && [[ "$hdsflag" == "y" ]]; then
	  echo "HD Server add-on can only be installed with product connect"
	  exit 7
	fi
	if [[ $basetype != "connect" ]] && [[ "$mcpflag" == "y" ]]; then
	  echo "MCP add-on can only be installed with product connect"
	  exit 7
	fi

	if [[ $basetype == "connect" ]]; then
	  echo "Installing product ARIS Connect"
	fi

	if [[ $basetype == "arcm" ]]; then
	  echo "Installing product ARIS Risk & Compliance Manager"
	fi

	if [[ $basetype == "api" ]]; then
	  echo "Installing product API Portal"
	fi

	if [[ $dbflag == "n" ]]; then
	  echo "External DB will used, Postgres will not be installed"
	else
	  echo "Standard database system (Postgres) will be installed"
	fi

	if [[ $arcmflag == "y" ]]; then
	  echo "Product ARCM will be installed as add-on"
	fi

	if [[ $hdsflag == "y" ]]; then
	   echo "Heavy Duty server will be installed as add-on"
	fi

	if [[ $mcpflag == "y" ]]; then
	   echo "MCP will be installed as add-on"
	fi

	if [[ $rmVolumesflag == "y" ]]; then
	   echo "Warning all docker volumes will be deleteted before the new container will be deployed."
	else
	   echo "All docker volume will remain with existing data."
	fi
}

writeVariables(){
    #echo "writeVariables"
    #echo $selectedParameterFile
	#echo "basetype=$basetype"
	echo "basetype=$basetype" >"$selectedParameterFile"
	#echo "dbflag=$dbflag"
	echo "dbflag=$dbflag" >>"$selectedParameterFile"
	#echo "arcmflag=$arcmflag"
	echo "arcmflag=$arcmflag" >>"$selectedParameterFile"
	#echo "hdsflag=$hdsflag"
	echo "hdsflag=$hdsflag" >>"$selectedParameterFile"
	echo "mcpflag=$mcpflag" >>"$selectedParameterFile"
	#echo "rmVolumesflag=$rmVolumesflag"
	echo "rmVolumesflag=$rmVolumesflag" >>"$selectedParameterFile"
}
getCommit(){
	local alwaysYesLocal=$1
	#echo "alwaysYes=$alwaysYes"
	#echo "rmVolumesflag=$rmVolumesflag"
	if [[ "$alwaysYesLocal" != "y" ]] && [[ "$rmVolumesflag" == "y" ]]; then
		while true; do
			read -p "Should all data in docker volumes be deleted (y/n)? " yn
			case $yn in
				[Yy]* ) rmVolumesflag="y"; alwaysYes=y; break;;
				[Nn]* ) rmVolumesflag="n"; break;;
				* ) echo "Please answer yes or no.";;
			esac
		done
		if [[ "$rmVolumesflag" == "y" ]]; then
		   echo "All volumes will be deleted!"
		else
		   echo "All volumes will not be deleted!"
		fi
	fi
}
checkDockerCompose() {
    #echo "checkDockerCompose"
	docker-compose version > /dev/null
	if [[ $? != 0 ]]; then
	  echo "Error: docker-compose not available."
	  exit 4
	fi
}
usage() {
    #echo "usage"
	echo "For the base product connect, api or arcm are possible values."
	echo "Connect addons can be added with parameter add_arcm and add_hds"
	echo "To avoid the interal DB Postgres, ext_db can be used."
	echo "With the parameter rm_volumes the docker volumes can be removed before deployment"
}
checkParameter() {
    #echo "checkParameter ${@}"
	if [[ $# -gt 0 ]]; then #use the requested parameter enhanced with defaults
		for arg in "$@"
		do
			case "$arg" in
				connect)
				   checkbase
				   basetype="$arg"
				   ;;
				api)
				   checkbase
				   basetype="$arg"
				   ;;
				arcm)
				   checkbase
				   ;;
				ext_db)
				   dbflag=n
				   ;;
				add_arcm)
				   arcmflag=y
				   ;;
				add_hds)
				   hdsflag=y
				   ;;
				add_mcp)
				   mcpflag=y
				   ;;
				rm_volumes)
				   rmVolumesflag=y
				   ;;
				-h|--help)
				   usage
					exit 0
				   ;;
				-y|-Y)
				   alwaysYes=y
				   ;;
				*)
					echo "Unknown call parameter has been used ${arg}."
					echo "Please check your call parameters."
					usage
					exit 6
				   ;;
			esac
		done
		setDefaultsForUnset
		writeVariables
	elif [[ -f $selectedParameterFile ]] ; then # use the stored paramter
	    echo $selectedParameterFile
		source $selectedParameterFile
	else #Use defaults for initial setting
		setDefaultsForUnset
		writeVariables
	fi
}

checkDockerCompose;
checkParameter "${@:1}"
getCommit $alwaysYes
