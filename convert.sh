#!/bin/bash
#
# Script to convert aiff files downloaded from Beatport to flac (with covers).
# It uses ffmpeg (that not deals with covers during conversion) and metaflac to
# apply covers to flac file.
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
#
# Script requirements:
# - ffmpeg
# - metaflac

# Check requirements
if [ $(ffmpeg -version &>/dev/null ; echo $?) -ne 0 ]; then
  echo "Please install ffmpeg"
  exit 1
fi

if [ $(metaflac --version &>/dev/null ; echo $? ) -ne 0 ]; then
  echo "Please install metaflac"
  exit 1
fi

# Each element in the loop is separated by newline rather than blank sign
IFS=$'\n'

for filename in $(ls *.aiff); do
  echo "Working on: $filename"

  # Files cames always with .aiff extension so we will remove last four letters
  # and replace them with "flac" (no dot)
  flac_filename="${filename%????}flac"

  # Convert file to .flac
  ffmpeg -i "$filename" "$flac_filename"

  # Test how many streams with images are in the audio file.
  if [ $(ffmpeg -i "$filename" 2>&1 | grep "Stream #0:3: Video" &>/dev/null; echo $?) -eq 0 ]; then
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

done
