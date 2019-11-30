#!/bin/bash

inputfile=$1

if [ ! -f "$inputfile" ]; then
    echo "Must be called with a text file, with at least 2 columns, separated by blanks"
    echo "first column should contain a name for the yaml file,"
    echo "second shound be a comma seperated list of app types surrounded \", "
    echo "and the optional third parameter could contain an folder path to be used for the yaml file, otherwise the current pwd will be used"
fi

while read -r name apptypes targetpath || [[ -n $name ]]; do
    [[ $name = \#* ]] && continue
    echo "Run createCompose.sh $name $apptypes $targetpath"
    source createCompose.sh $name $apptypes $targetpath
done < $inputfile