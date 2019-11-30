#!/bin/bash

#computername=$(echo $HOSTNAME | cut -d"." -f1)
#CC_LIST=`cat $arisDockerSetupBase/config/default/mail-cc.lst`
#adminmail=thomas.scheer@softwareag.com

#continue only if all docker containers were successfully started.
crashed=$($arisDockerSetupBase/scripts/countcontainers.sh crashed )
if [ "$crashed" == 0 ]
then
    # Status mail
    echo ++++ Success: All containers started.++++  >> $arisDockerComposeLog 2>&1
    #echo ++++ send success mail ..  >> $arisDockerComposeLog 2>&1
    #cat $arisDockerComposeLog | tr -d \\r | tr -cd '\11\12\15\40-\176' | mailx -S smtp=mailhost.hq.sag -r "$computername"@eur.ad.sag -c "$CC_LIST" -s 'Docker-Installation of '$codeline' on '$computername' finished' -a "$arisDockerComposeLog" -v "$adminmail"
else
    echo ++++ Fail: Not all containers successfully started.++++  >> $arisDockerComposeLog 2>&1
    #echo ++++ send failed mail ..  >> $arisDockerComposeLog 2>&1
    #mailx -S smtp=mailhost.hq.sag -r "$computername"@eur.ad.sag -c "$CC_LIST" -s 'Docker-Installation of '$codeline' on '$computername' failed' -v "$adminmail"  < "$arisDockerComposeLog"
fi

echo ++++ DONE ++++  >> $arisDockerComposeLog 2>&1
date >> $arisDockerComposeLog

