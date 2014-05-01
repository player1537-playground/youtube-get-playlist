#!/bin/bash

YOUTUBE_DIR=${YOUTUBE_DIR:-$HOME/etc/youtube}
YOUTUBE_DL_BIN=${YOUTUBE_DL_BIN:-youtube-dl}
BTSYNC_DIR=${BTSYNC_DIR:-/mnt/usb/btsync}
YOUTUBE_DL_RATE_LIMIT=${YOUTUBE_DL_RATE_LIMIT:-500k}
YOUTUBE_DL_AUDIO_FORMAT=${YOUTUBE_DL_AUDIO_FORMAT:-mp3}
YOUTUBE_DL_PLAYLIST_START=${YOUTUBE_DL_PLAYLIST_START:-1}
YOUTUBE_DL_PLAYLIST_END=${YOUTUBE_DL_PLAYLIST_END:-last}
YOUTUBE_DL_VIDEO_FORMAT=${YOUTUBE_DL_VIDEO_FORMAT:-18}
TYPE=${TYPE:-playlist}

function get-music-from-playlist() {
    local url
    url="https://www.youtube.com/playlist?list=$id"
    printf "Downloading playlist from %s\n" "$url"
    $YOUTUBE_DL_BIN -r $YOUTUBE_DL_RATE_LIMIT \
	--playlist-start $YOUTUBE_DL_PLAYLIST_START \
	--playlist-end $YOUTUBE_DL_PLAYLIST_END \
	--format $YOUTUBE_DL_VIDEO_FORMAT \
	--extract-audio \
	--audio-format $YOUTUBE_DL_AUDIO_FORMAT \
	--output "$dir/%(title)s.%(ext)s" \
	$url
}

function get-music-from-video() {
    local url
    url="https://www.youtube.com/watch?v=$id"
    printf "Downloading video from %s\n" "$url"
    $YOUTUBE_DL_BIN -r $YOUTUBE_DL_RATE_LIMIT \
	--format $YOUTUBE_DL_VIDEO_FORMAT \
	--extract-audio \
	--audio-format $YOUTUBE_DL_AUDIO_FORMAT \
	--output "$dir/%(title)s.%(ext)s" \
	$url
}

function copy-music-to-btsync() {
    cp "$dir"/*.$YOUTUBE_DL_AUDIO_FORMAT "$btsyncdir/"
}

function main {
    local config playlist playlistname playlistid btsyncdir
    
    for config in TYPE YOUTUBE_DIR YOUTUBE_DL_BIN BTSYNC_DIR YOUTUBE_DL_RATE_LIMIT \
	          YOUTUBE_DL_AUDIO_FORMAT YOUTUBE_DL_PLAYLIST_START YOUTUBE_DL_PLAYLIST_END \
                  YOUTUBE_DL_VIDEO_FORMAT; do
	printf "%-40s: %s\n" $config ${!config}
    done
    
    for playlist; do
	name=${playlist%:*}
	id=${playlist#*:}
	dir=$YOUTUBE_DIR/$name
	btsyncdir=$BTSYNC_DIR/$name
	
	: ${name:?Name required} 
	: ${id:?ID required}
	mkdir -p "$dir"
	mkdir -p "$btsyncdir"
	
	printf "Downloading %s\n" "$playlistname"
	case $TYPE in
	    playlist) get-music-from-playlist;;
	    video) get-music-from-video;;
	esac

	printf "Copying music to %s\n" "$btsyncdir"
	copy-music-to-btsync
    done
}

main "$@"
