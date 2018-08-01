#!/bin/bash
if [ $UID -ne 0 ]; then
    echo "Install failed: you must be logged in as 'root' to install."
    echo "Use command 'sudo -i', then enter root password and then try again."
    exit 1
fi
cd ~
mkdir qBittorrent/
mkdir 
cp -R ~/.config/qBittorrent/* ~/qBittorrent
cp~/.local/share/data/qBittorrent/BT_backup/