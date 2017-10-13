#!/bin/bash

set -e
# Downloads a playlist (only videos not downloaded yet) to the current folder
# Feel free to hack around to whatever suits your needs

archive="archive.txt" # The text file where youtube-dl will collect the ids of downloaded videos
playlist="https://www.youtube.com/playlist?list=???" # link to the playlist to be downloaded
post_download_trigger="bash ./add_to_playlist.sh {}" # script to pass newly downloaded files to


## Options used:
# -i : ignore failures. Skip a video if it can't be downloaded (e.g. because it was removed) and don't just die
# -f "bestaudio/best" : format. use best available audio only format, otherwise best format with muxed audio and video
# --playlist-reverse : start at the end of the playlist (the oldest video). use this if you want the videos downloaded in the same order they were added to the playlist
# --exec './add_to_playlist.sh {}' : pass the newly downloaded file to this script. Fully optional.
# --download-archive foo.txt : the text file youtube-dl should use to keep track of already downloaded files
# -x : extract audio. Only gets used if there isn't an audio only file available anyways
# --add-metadata : try to guess some metadata and add that to the downloaded file
# $playlist : link to the playlist

youtube-dl -i -f "bestaudio/best" --playlist-reverse --exec "$post_download_trigger" --download-archive "$archive" -x --add-metadata "$playlist" || true
# hack because if one or more videos are blocked, youtube-dl will return exit code 1, even if other downloads were sucessful
# This is suboptimal, because it will always show up as sucessful in systemd
