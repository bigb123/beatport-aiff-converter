# Beatport aiff converter
Script that uses ffmpeg to convert big and uncompressed aiff files downloaded from Beatport to lossless files (including cover art).

It can convert it to flac or Apple alac (in m4a container). It uses metaflac or mp4art to apply cover art.

Tested on MacOS Mojave 10.14.2

## Prerequisities
- ffmpeg
- jq
- metaflac - for flac cover art apply
- mp4v2 (with mp4art command) - for alac cover art apply

On Mac you can install them via brew. On other linuxes use distribution specific package manager.

## Usage
Run the script adding path to files to convert after "-d" option.
```
chmod u+x convert.sh
/path/to/convert.sh -d /dir/with/aiffs [flac|alac|both]
```
It will produce chosen files with cover arts
