#!/bin/bash

function countContainers() {
        docker ps -q -f label=com.softwareag.product=ARIS $1 | wc -l
}

function countCrashedContainers() {
        docker ps -a  -f label=com.softwareag.product=ARIS | grep -v -F 'Exited (0)' | grep -c -F 'Exited ('
}

TYPE=${1-all}

case $TYPE in
        running) COUNT_FUNCTION="countContainers"; shift;;
        crashed) COUNT_FUNCTION="countCrashedContainers"; shift;;
        all) COUNT_FUNCTION="countContainers -a"; shift;;
esac

$COUNT_FUNCTION
