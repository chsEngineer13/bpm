#!/bin/bash

templatesPath=${arisDockerSetupBase}/compose/templates/
yamlfileList="-f ${templatesPath}docker-base-net.template"

getYamlFile(){
    local yamlFileName=$1
    local yamlFilePath=$2
	if [ -n "$yamlFileName" ]; then
		yamlfile=$yamlFileName.yml
	else
		echo "Frist parameter must contain a name for the resulting yml file."
		exit
	fi
	if [ -n "$yamlFilePath" ]; then
		yamlfile=$yamlFilePath"/"$yamlfile
		if [ ! -d "$yamlFilePath" ]; then
			mkdir -p $yamlFilePath
		fi
	fi
	if [ -f "$yamlfile" ]; then
		mv -vf "$yamlfile" "$yamlfile".old
	fi
}
addOverlays(){
	if [[ $apptypes =~ api ]]; then
		if [[ $apptypes =~ ecp ]]; then
			yamlfileList+=" -f ${templatesPath}ecp-api-overwrite.template"
		fi
		if [[ $apptypes =~ cop ]]; then
			yamlfileList+=" -f ${templatesPath}cop-api-overwrite.template"
		fi
	fi
}
createYamlfileList(){
	if [ -n "$1" ]; then
		apptypes=${1//apiportalbundle/api} #replace in $2 apiportalbundle with api
		OIFS=$IFS
		IFS=','
		for app in $apptypes
		do
			apptemplate=${templatesPath}${app}".template"
			if [ -f "$apptemplate" ]; then
				echo "Adding template file $apptemplate to yaml file"
				yamlfileList+=" -f $apptemplate"
			else
				echo "Unknow app type $app in the second paramenter"
				exit
			fi
		done
		IFS=$OIFS
		addOverlays
	else
		echo "Second parameter must contain a comma separated list of app types."
		exit
	fi
}

getYamlFile $1 $3
echo "Target yaml file $yamlfile"
createYamlfileList "$2"
echo "docker-compose $yamlfileList config > $yamlfile"
docker-compose $yamlfileList config > $yamlfile
echo "The yaml file $yamlfile has been created"

