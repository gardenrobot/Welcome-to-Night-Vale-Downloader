#!/bin/bash

if [[ ! $(ps -e | grep wnv) ]]; then
	echo 'Starting Welcome to Night Vale downloader'
	tmux new-session -d -n 'WNV downloader' './wnv.exe "'"f:\\\\\\\\Data\\\\Shared\\\\Podcasts\\\\Welcome to Night Vale\\\\"'"'
fi
