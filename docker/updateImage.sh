# This script builds the current docker image and pushes it.

cp ../yt2fof.sh .
docker build -t tmodica/yt2fof-docker .
docker push tmodica/yt2fof-docker
rm yt2fof.sh