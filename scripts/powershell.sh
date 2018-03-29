#!/bin/bash
## First check if there is a container that exists
EXISTS=`docker ps -a | awk -F " " '{print $NF}'| grep -i powershell`

if [ $? -ne 0 ]
then
  docker run -it -v ~/.aws/:/root/.aws --name powershell maishsk/awspowershell.netcore
else
  ## Check to see if the container is running in the background
  IS_RUNNING=`docker ps -a | grep -i powershell | grep Up`
  if [ $? -ne 0 ]
  ## Container is not running - start it
  then
    docker start -i powershell
  ## Container is running in another shell - take control
  else
    docker stop powershell
    docker start -i powershell
  fi
fi
