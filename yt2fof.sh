#!/bin/sh

# ****** Configuration and setup ******

CONFIG_FILE_NAME="source.y2f"

# only split on newlines
IFS=$'\n'

# ****** Main functionality ******

processDirectory() {
  local DIR="$TARGET_DIR/$1"
  cd "$DIR" || return
  if [ -e "$DIR/$CONFIG_FILE_NAME" ]; then
    echo "- - Found $CONFIG_FILE_NAME file in $1. Parse and process."
    processConfig "$DIR"
  else
    echo "- - No $CONFIG_FILE_NAME file in $DIR. Skip that."
  fi
  cd .. || exit
}

processConfig() {
    # shellcheck source=/dev/null
    . "$1/$CONFIG_FILE_NAME"
    echo "- - Read properties"
    echo "- - - YOUTUBE_URL = $YOUTUBE_URL"
    echo "- - - START_TIME = $START_TIME"
    echo "- - - END_TIME = $END_TIME"
    if [ -e "guitar.ogg" ]; then
      echo "- - Remove old guitar.ogg"
      rm guitar.ogg
    fi
    echo "- - Running youtube-dl and extracting sound file"
    youtube-dl "$YOUTUBE_URL" -f bestaudio -x --audio-format vorbis --postprocessor-args "-ss $START_TIME -to $END_TIME" -o guitar.raw
}

# ****** Actual script ******

echo " *** This is yt2fof ***"
echo "USAGE: yt2fof.sh [<targetDir>]"
echo " * The script will either find a $CONFIG_FILE_NAME in the target directoy and process it directly"
echo " * or traverse all of the target's direct subdirectories looking for and processing $CONFIG_FILE_NAME."

# popd to optional target directory
if [ -n "$1" -a -d "$(pwd)/$1" ]; then
  echo "- switch into target directory '$1'"
  cd "$1" || exit
fi

# shortuct for docker mode if sources subdirectory exists
if [ -z "$1" -a -d "$(pwd)/sources" ]; then
  echo "- switch into target directory 'sources'"
  cd sources || exit
fi

TARGET_DIR=$(pwd)

if [ -e "$TARGET_DIR/$CONFIG_FILE_NAME" ]; then
    echo "- found $CONFIG_FILE_NAME in target directory -> no traversal of subdirectories."
    processConfig "$TARGET_DIR"
    exit
fi

echo "- Found no $CONFIG_FILE_NAME in target directory -> traverse subdirectories."
for SUBDIR in $(find .  -maxdepth 1 -mindepth 1 -type d);
do
   echo "- Processing subdirectory $SUBDIR";
   processDirectory "$SUBDIR"
   echo "- ****************************************"
done
