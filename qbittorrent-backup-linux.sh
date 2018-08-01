#!/bin/bash
if [ $UID -ne 0 ]; then
    echo "Install failed: you must be logged in as 'root' to install."
    echo "Use command 'sudo -i', then enter root password and then try again."
    exit 1
fi
cd ~
mkdir qBittorrent/
mkdir BT_backup/
cp -R ~/.config/qBittorrent/* ~/qBittorrent
cp -R ~/.local/share/data/qBittorrent/BT_backup/* ~/BT_backup