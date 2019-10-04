# This Dockerfile builds an image with all dependencies to run the yt2fof.sh script in it.

FROM mikenye/youtube-dl
LABEL maintainer="tonymodica@github"

COPY ./yt2fof.sh /workdir
RUN chmod 777 /workdir/yt2fof.sh

ENTRYPOINT ["/workdir/yt2fof.sh", "sources"]
