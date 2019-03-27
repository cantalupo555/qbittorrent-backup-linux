#!/bin/bash
if [ $UID -ne 1000 ]; then
    echo "Install failed: you can not be logged in as 'root'"
    exit 1
fi
o1(){
	echo ""
	echo "-------------------------------------------------------------------------"
	echo "-------------------------------------------------------------------------"
	echo "-------------------------------------------------------------------------"
	echo "Press ENTER to go back!"	
	echo ""
	read v	
}

while true 
do
	clear
	echo "_________________________________________________________________________"
	echo "|                                                                       |"
	echo "|                            @cantalupo555                              |"
	echo "|                                                                       |"
	echo "| 1 - Backup qBittorrent                                                |"
	echo "| 2 - Restore qBittorrent                                               |"
	echo "| 3 - Exit                                                              |"
	echo "|_______________________________________________________________________|"
	echo ""
	echo "Please select your option 1 to 3:"
	read op

	case $op in 
		1) while true; do
				clear
				cd ~
				mkdir qBittorrent-Backup-Linux/
				mkdir qBittorrent-Backup-Linux/qBittorrent/
				mkdir qBittorrent-Backup-Linux/BT_backup/
				mkdir qBittorrent-Backup-Linux/logs/
				cp -R ~/.config/qBittorrent/* ~/qBittorrent-Backup-Linux/qBittorrent
				cp -R ~/.local/share/data/qBittorrent/BT_backup/* ~/qBittorrent-Backup-Linux/BT_backup
				cp -R ~/.local/share/data/qBittorrent/logs/* ~/qBittorrent-Backup-Linux/logs
				zip -r -0 qBittorrent-Backup-Linux.zip qBittorrent-Backup-Linux/
				mv qBittorrent-Backup-Linux.zip ~/Downloads
				rm -rf ~/qBittorrent-Backup-Linux/
				echo ""
				echo "-------------------------------------------------------------------------"
				echo "-------------------------------------------------------------------------"
				echo "-------------------------------------------------------------------------"
				echo "Process completed"
				o1
				if [ -z "$v" ]; then
				break
				fi
				done
				;;

		2) while true; do
				clear
				cd ~/Downloads
				unzip qBittorrent-Backup-Linux.zip
				cd qBittorrent-Backup-Linux/
				rm -rf ~/.config/qBittorrent
				rm -rf ~/.local/share/data/qBittorrent/BT_backup
				rm -rf ~/.local/share/data/qBittorrent/logs
				mv qBittorrent/ ~/.config/
				mv BT_backup/ ~/.local/share/data/qBittorrent/
				mv logs/ ~/.local/share/data/qBittorrent/
				cd ..
				rm -rf qBittorrent-Backup-Linux/
				echo ""
				echo "-------------------------------------------------------------------------"
				echo "-------------------------------------------------------------------------"
				echo "-------------------------------------------------------------------------"
				echo "Process completed"
				o1
				if [ -z "$v" ]; then
				break
				fi
				done
				;;
		
		3)
				clear
				echo "-------------------------------------------------------------------------"
				echo "-------------------------------------------------------------------------"
				echo "-------------------------------------------------------------------------"
				echo "Exit..."
				exit
				sleep
				clear
				break
				;;

		*)
				clear		
				echo "-------------------------------------------------------------------------"
				echo "-------------------------------------------------------------------------"
				echo "-------------------------------------------------------------------------"
				echo "Invalid Option!"
				sleep 1
				echo ""
				;;
	esac
done
