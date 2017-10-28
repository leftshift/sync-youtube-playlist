#!/bin/bash

set -e
# WARNING: Don't run this anywhere where you have audio files you want to keep; they'll be uploaded to the cloud and removed. maybe not what you want.
# Downloads new files from a youtube playlists and uploads them to an owncloud 
# Feel free to hack around to whatever suits your needs

webdav_folder_url="" # base folder for downloaded files, playlist file and archive file
username=$(< "user.txt") # username for owncloud
password=$(< "pass.txt") # password for owncloud

archive="archive.txt" # The text file where youtube-dl will collect the ids of downloaded videos
playlist_file="playlist.m3u" # m3u playlist file. Needs to be specified here so it can be up- and downloaded
playlist="https://www.youtube.com/playlist?list=" # link to the playlist to be downloaded
post_download_trigger="bash ./add_to_playlist.sh {}" # script to pass newly downloaded files to


# https://gist.github.com/cdown/1163649
urlencode() {
    # urlencode <string>
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C
    
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
    
    LC_COLLATE=$old_lc_collate
}


# download archive and playlist
echo "[sync] Downloadig archive and playlist"
wget --user "$username" --password "$password" "$webdav_folder_url$archive" -N --no-check-certificate
wget --user "$username" --password "$password" "$webdav_folder_url$playlist_file" -N --no-check-certificate

echo "[sync] Starting ytdl"
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


echo "[sync] youtube-dl finished!"

shopt -s nullglob
for file in {*.ogg,*.m4a}; do
    echo "[sync] uploading $file"
    escaped_filename="$(urlencode "$file")"
    curl -g --user "$username:$password" -T "$file" "$webdav_folder_url$escaped_filename"
    rm "$file"
done

curl --user "$username:$password" -T "$archive" "$webdav_folder_url$(urlencode "$archive")"
curl --user "$username:$password" -T "$playlist_file" "$webdav_folder_url$(urlencode "$playlist_file")"

exit 0 
