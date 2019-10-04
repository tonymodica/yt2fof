#!/bin/bash

echo " *** This runs yt2fof in a docker container with all required tool dependencies ***"
echo "USAGE: yt2fof-docker.sh <pathToFofFolders> <resultFolder>"

WORKDIR="/data"

if [ -z "$1" -o -z "$2" ]; then
  echo "ERROR: Both a source and a target folder must be specified (current: source=$1 target=$2)"
  exit
fi

echo "[docker-wrapper] create container"
docker create -i --name yt2fof-container --entrypoint="./yt2fof.sh" vimagick/youtube-dl
echo "copy yt2fof.sh to container"
docker cp yt2fof.sh yt2fof-container:$WORKDIR/
echo "[docker-wrapper] copy source folder to container"
docker cp "$1" yt2fof-container:/data/sources
echo "[docker-wrapper] start container"
docker start -i yt2fof-container
#echo "[docker-wrapper] execute script in container"
#docker exec -ti yt2fof-container sh -c "./yt2fof.sh sources"
echo "[docker-wrapper] copy results from container"
docker cp yt2fof-container:$WORKDIR/sources "$2"
echo "[docker-wrapper] delete container"
docker rm -f yt2fof-container
