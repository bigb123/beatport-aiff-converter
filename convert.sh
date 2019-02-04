#!/bin/bash
#
# Script to convert aiff files downloaded from Beatport to lossless format (with covers).
# It uses ffmpeg (that not deals with covers during conversion), metaflac to
# apply covers to flac file and mp4art in case of alac files (m4a container).
#
# Streams with images available in files from Beatport: (for type numbers
# reference read "metaflac -h":
#
# stream 1 - A bright coloured fish - type 17
# stream 2 - Publisher/Studio logotype - type 20
# stream 3 - Cover (front)  - type 3
#
# or
#
# stream 1 - A bright coloured fish - type 17
# stream 2 - Cover (front)  - type 3
#
# In case of alac it's just simple apply cover art to file with no others arts.
#
# Script requirements:
# - ffmpeg
# - metaflac (optionally)
# - mp4v2 (optionally)

CODEC="$1"

if [ "" == "$CODEC" ]; then
  CODEC="alac"
fi

# usage description
usage () {
  echo
  echo "Script to convert aiff files (downloaded from Beatport) to lossless format"
  echo "like flac or alac (m4a container). If no argument specified files will be "
  echo "converted to alac."
  echo
  echo "Usage:"
  echo "$0 [flac|alac|both]"
  echo
}

###
#
# FLAC
#
###

flac_convert() {

  filename="$1"

  echo "Flac filename: $filename"
  # Files comes always with .aiff extension so we will remove last four letters
  # and replace them with "flac" (no dot)
  flac_filename="${filename%????}flac"

  # Convert file to .flac
  ffmpeg -i "$filename" "$flac_filename"

  # Test how many streams with images are in the audio file.
  if [ $(ffprobe "$filename" 2>&1 | grep "Stream #0:3: Video" &>/dev/null; echo $?) -eq 0 ]; then
    # There are 3 streams. That means:
    # - the 1st one is "A bright coloured fish"
    # - 2nd is Publisher/Studio logotype
    # - 3rd is Cover (front)

    # Cover (front)  - type 3
    pic_name="cover.mjpeg"
    ffmpeg -i "$filename" -map 0:3 "$pic_name"
    metaflac --import-picture-from="3||||$pic_name" "$flac_filename"
    rm "$pic_name"

    # Publisher/Studio logotype - type 20
    pic_name="logotype.mjpeg"
    ffmpeg -i "$filename" -map 0:2 "$pic_name"
    metaflac --import-picture-from="20||||$pic_name" "$flac_filename"
    rm "$pic_name"

    # A bright coloured fish - type 17
    pic_name="bright_coloured_fish.png"
    ffmpeg -i "$filename" -map 0:1 "$pic_name"
    metaflac --import-picture-from="17||||$pic_name" "$flac_filename"
    rm "$pic_name"

  else
    # There are only 2 streams:
    # - the 1st one is "A bright coloured fish"
    # - 2nd is Cover (front)
    # A bright coloured fish - type 17

    # Cover (front)  - type 3
    pic_name="cover.mjpeg"
    ffmpeg -i "$filename" -map 0:2 "$pic_name"
    metaflac --import-picture-from="3||||$pic_name" "$flac_filename"
    rm "$pic_name"

    pic_name="bright_coloured_fish.png"
    ffmpeg -i "$filename" -map 0:1 "$pic_name"
    metaflac --import-picture-from="17||||$pic_name" "$flac_filename"
    rm "$pic_name"
  fi
}


###
#
# ALAC
#
###

alac_convert() {

  filename="$1"

  echo "Alac filename: $filename"
  # Files comes always with .aiff extension so we will remove last four letters
  # and replace them with "m4a" (no dot)
  alac_filename="${filename%????}m4a"

  # Convert file to alac (-vn stands for "no video". ffmpeg thinks that cover
  # art included into aiff file is a video so it creates mp4 video file. We'd like
  # to avoid it as it makes problems with cover art display in Mac Finder)
  ffmpeg -i "$filename" -acodec alac -vn "$alac_filename"

  # Test how many streams with images are in the audio file.
  if [ $(ffmpeg -i "$filename" 2>&1 | grep "Stream #0:3: Video" &>/dev/null; echo $?) -eq 0 ]; then
    # There are 3 streams and the last one is cover art.

    # Cover (front)
    pic_name="cover.mjpeg"
    ffmpeg -i "$filename" -map 0:3 "$pic_name"
    mp4art --add "$pic_name" "$alac_filename"
    rm "$pic_name"

  else
    # There are only 2 streams and second one is a cover art.

    # Cover (front)
    pic_name="cover.mjpeg"
    ffmpeg -i "$filename" -map 0:2 "$pic_name"
    mp4art --add "$pic_name" "$alac_filename"
    rm "$pic_name"
  fi
}

# Check requirements
if [ $(ffmpeg -version &>/dev/null ; echo $?) -ne 0 ]; then
  echo "Please install ffmpeg"
  exit 1
fi

# Flac requirements
if [ "flac" == "$CODEC" ] || [ "both" == "$CODEC" ]; then
  if [ $(metaflac --version &>/dev/null ; echo $? ) -ne 0 ]; then
    echo "Please install metaflac"
    exit 1
  fi
fi

# Alac requirements
if [ "alac" == "$CODEC" ] || [ "both" == "$CODEC" ]; then
  if [ $(mp4art --version &>/dev/null ; echo $? ) -ne 0 ]; then
    echo "Please install mp4v2"
    exit 1
  fi
fi

while getopts "h" optname; do
  case "$optname" in
    "h")
      usage
    ;;
  esac
done

# Each element in the loop is separated by newline rather than blank sign
IFS=$'\n'

for filename in $(find . -name "*.aiff"); do

  if [ "flac" == "$CODEC" ] || [ "both" == "$CODEC" ]; then
    flac_convert "$filename"
  fi

  if [ "alac" == "$CODEC" ] || [ "both" == "$CODEC" ]; then
    alac_convert "$filename"
  fi

done

# # Leaving for the future
# DIRNAME=$(dirname "$0")
# find . -name "*.aiff" -exec "$DIRNAME"/flac_convert.sh "{}" \;
