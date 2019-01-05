# beatport-aiff-to-flac-converter
Script that uses ffmpeg and metaflac to convert big and uncompressed aiff files downloaded from Beatport to loseless flac files (including cover art).

Tested on MacOS Mojave 10.14.2

## Prerequisities
- ffmpeg
- metaflac

On Mac you can install them via brew. On other linuxes use distribution specific package manager.

## Usage
Just go to directory with .aiff files and run script.
```
chmod u+x convert.sh
cd /dir/with/aiffs
/path/to/convert.sh
```
It will produce .flac files with cover arts
