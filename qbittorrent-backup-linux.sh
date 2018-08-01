#!/bin/bash
if [ $UID -ne 0 ]; then
    echo "Install failed: you must be logged in as 'root' to install."
    echo "Use command 'sudo -i', then enter root password and then try again."
    exit 1
fi
cd ~
mkdir qBittorrent-Backup-Linux/
mkdir qBittorrent-Backup-Linux/qBittorrent/
mkdir qBittorrent-Backup-Linux/BT_backup/
cp -R ~/.config/qBittorrent/* ~/qBittorrent-Backup-Linux/qBittorrent
cp -R ~/.local/share/data/qBittorrent/BT_backup/* ~/qBittorrent-Backup-Linux/BT_backup
zip -r -0 qBittorrent-Backup-Linux.zip qBittorrent-Backup-Linux/