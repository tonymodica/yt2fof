#!/bin/sh

# ****** Configuration and setup ******************************************************************

CONFIG_FILE_NAME="source.y2f"

# only split on newlines
IFS=$'\n'

# ****** Main functionality ***********************************************************************

# Calls youtube-dl
# param $1: the url to download
# param $2: the start time
# param $2: the end time
callYoutubeDl() {
  youtube-dl "$1" -f bestaudio -x --audio-format vorbis --postprocessor-args "-ss $2 -to $3" -o guitar.raw
}

# Processes a directory - check if it contains a source config file, process that file if it exists.
# param $1: the directory to process
processDirectory() {
  DIR="$1"
  cd "$DIR" || return
  if [ -e "$DIR/$CONFIG_FILE_NAME" ]; then
    echo "- - Found $CONFIG_FILE_NAME file in $1. Parse and process."
    processConfig "$DIR/$CONFIG_FILE_NAME"
  else
    echo "- - No $CONFIG_FILE_NAME file in $DIR. Skip that."
  fi
  cd .. || exit
}

# Processes a source config file.
# param $1: the source config file
processConfig() {
    # shellcheck source=/dev/null
    . "$1"
    echo "- - Read properties"
    echo "- - - YOUTUBE_URL = $YOUTUBE_URL"
    echo "- - - START_TIME = $START_TIME"
    echo "- - - END_TIME = $END_TIME"
    rm guitar.old 2> /dev/null
    if [ -e "guitar.ogg" ]; then
      echo "- - Rename existing guitar.ogg to guitar.old"
      mv guitar.ogg guitar.old
    fi
    echo "- - Running youtube-dl and extracting sound file"
    callYoutubeDl "$YOUTUBE_URL" "$START_TIME" "$END_TIME"
}

# ****** Actual script ****************************************************************************

echo " *** This is yt2fof.sh ***"
echo " * The script will either find a $CONFIG_FILE_NAME in the target directoy and process it directly"
echo " * or traverse all of the target's direct subdirectories looking for and processing $CONFIG_FILE_NAME."
if [ -z "$1" ] || [ ! -d "$1" ]; then
  echo "USAGE: yt2fof.sh [<targetDir>]"
else
  echo "- switch into target directory '$1'"
  cd "$1" || exit
fi
echo

# shortuct for docker mode if sources subdirectory exists
if [ -z "$1" ] && [ -d "./sources" ]; then
  echo "- seems we are used in a docker container -> switch into target directory 'sources'"
  cd sources || exit
fi

TARGET_DIR=$(pwd)

if [ -e "$TARGET_DIR/$CONFIG_FILE_NAME" ]; then
    echo "- found $CONFIG_FILE_NAME in target directory -> no traversal of subdirectories."
    processConfig "$TARGET_DIR"
    exit
fi

echo "- Found no $CONFIG_FILE_NAME in target directory -> traverse all direct subdirectories."
for SUBDIR in $(find .  -maxdepth 1 -mindepth 1 -type d);
do
   echo "- Processing subdirectory $SUBDIR";
   processDirectory "$TARGET_DIR/$SUBDIR"
   echo "- ****************************************"
done
