#!/bin/bash

# Prepends name of downloaded file to m3u playlist
# m3u playlists get autodiscovered and added to players by android


# Hack to repack .opus files into an .ogg container, because android doesn't consider .opus media files and just ignores them in playlists. Optional if you don't care about android
pack_opus_into_ogg=true
playlist="playlist.m3u"

filename=$(basename "$1")
filefront="${filename%.*}"
extension="${filename##*.}"


# make sure the playlist file exists
touch "$playlist"

if [ "$extension" == "opus" ] && [ "$pack_opus_into_ogg" = true ] ; then
	ffmpeg -i "$filename" -codec:a copy "$filefront.ogg"
	rm "$filename"
	filename="$filefront.ogg"
fi

# prepend newly downloaded file to playlist
echo -e "$filename\n$(cat "$playlist")" > "$playlist"
