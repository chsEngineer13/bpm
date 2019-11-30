#!/bin/bash

## workaround for docker bug (must be called before compose down
echo +++ docker clean ARIS network +++
remainingNetworks=($(docker network ls -q -f label=com.docker.compose.network=arisnet))
if [ "${#remainingNetworks[@]}" -eq 1 ] ; then
for i in $(docker network inspect -f '{{range .Containers}}{{.Name}} {{end}}' ${remainingNetworks[@]}); do
docker network disconnect -f ${remainingNetworks[@]} $i;
done;
fi
