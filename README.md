# Beatport aiff converter
Script that uses ffmpeg to convert big and uncompressed aiff files downloaded from Beatport to lossless files (including cover art).

It can convert it to flac or Apple alac (in m4a container). It uses metaflac or mp4art to apply cover art.

Tested on MacOS Mojave 10.14.2

## Prerequisities
- ffmpeg
- metaflac - for flac cover art apply
- mp4v2 (with mp4art command) - for alac cover art apply

On Mac you can install them via brew. On other linuxes use distribution specific package manager.

## Usage
Just go to directory with .aiff files and run script.
```
chmod u+x convert.sh
cd /dir/with/aiffs
/path/to/convert.sh flac|alac|both
```
It will produce chosen files with cover arts
