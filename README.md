# a collection of scripts for keeping a local copy of a youtube playlist or sync it somewhere else

## download.sh

Download all files from a youtube playlist to the current working directory; add them to a playlist file in the order they appear in the playlist

You'll have to change:
* playlist url

## download-upload-upload-owncloud.sh

Do the same as download.sh, but upload all files to owncloud and delete local copies.

You'll have to change:
* playlist url
* webdav_folder_url to the url of the target folder in your owncloud's webDav access.
* create files `user.txt` and `pass.txt` which contain your owncloud's username and password
