#!/bin/bash

inputfile=$1
scenario=$2

targetpath=$arisDockerSetupBase
scriptdir=$arisDockerSetupBase/compose
composefile=docker-compose

if [ ! -f "$inputfile" ]; then
    echo "Must be called with a text file, with 2 columns, separated by blanks"
    echo "first column should contain a name for the scenario,"
    echo "second shound be a comma seperated list of app types surrounded \", "
    exit
fi
#Switch to composedir to use .env, otherwise it would not work
cd $scriptdir
while read -r name apptypes && [[ -n $name ]]; do
    if [[ $name = $scenario ]]; then
        echo "Create compose file for $scenario"
        echo "with createCompose.sh $composefile $apptypes $targetpath"
        source createCompose.sh "$composefile" "$apptypes" "$targetpath"
    fi
done < $inputfile
cd $OLDPWD