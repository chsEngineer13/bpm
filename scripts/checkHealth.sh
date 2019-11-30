#!/bin/bash

countContainerInHealthState(){
   local stateToCount=$1
   shift
   local expectedContainer=(${@})
   docker inspect --format='{{.State.Health.Status}}' "${expectedContainer[@]}" | grep -c "${stateToCount}"
}
checkContainerHealthy(){
    local baseType=$1
	local arisDockerSetupBase=$2
	local timeoutLocal=${timeout:=1200}
	#echo $timeoutLocal
	local waittime=0
	local sleeptime=5
	while : ; do  	   
	   local expectedContainer=($(docker-compose -p ${baseType} -f "/home/kpodres/aris/docker-compose.yml" ps -q))
	   #echo "expectedContainer=${#expectedContainer[@]}"
	   if [ "${#expectedContainer[@]}" -gt 0 ]; then
		   sleep "$sleeptime" 
		   let waittime+=sleeptime;
		   #echo "timeoutCount=$timeoutCount"
		   local count=$(docker inspect --format='{{.State.Running}}' "${expectedContainer[@]}" |  grep -c -F 'false')
		   #echo "count exited $count"
		   if [[ $count -gt 0 ]]; then
			  echo "found $count container exited, please check container states" 
			  echo "found $count container exited, please check container states" >> $arisDockerComposeLog 2>&1
			  return 8
		   fi   
		   #local countStarting=$(docker inspect --format='{{.State.Health.Status}}' "${expectedContainer[@]}" | grep -c starting)
		   local countStarting=$(countContainerInHealthState "starting" "${expectedContainer[@]}")
		   #echo "countStarting=$countStarting"
		   #local countUnhealty=$(docker inspect --format='{{.State.Health.Status}}' "${expectedContainer[@]}" | grep -c unhealthy)
		   local countUnhealty=$(countContainerInHealthState "unhealthy" "${expectedContainer[@]}")
		   #echo "countUnhealty=$countUnhealty"
		   let count="$countStarting"+"$countUnhealty"
		   if [[ $count -eq 0 ]]; then
			  break;
		   else
			  if [[ $waittime -ge $timeoutLocal ]] ; then
				echo "Stop waiting for $count unhealty container to get healty, timeout after $waittime seconds." 
				echo "Stop waiting for $count unhealty container to get healty, timeout after $waittime seconds." >> $arisDockerComposeLog 2>&1
				return 8
			  fi
			  echo -en "Wait since ${waittime} sec for $count unhealthy or starting container to get healthy. \r"
		   fi
		else
		   echo "No Container found for /home/kpodres/aris/docker-compose.yml." 
		   echo "No Container found for /home/kpodres/aris/docker-compose.yml."   >> $arisDockerComposeLog 2>&1
		   return 9
		fi 		
	done
	echo "All container are up and healthy after ${waittime} sec."
	echo "All container are up and healthy after ${waittime} sec." >> $arisDockerComposeLog 2>&1
	return 0
}

checkContainerHealthy $1 $2
