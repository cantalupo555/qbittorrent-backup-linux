#!/bin/bash
if [ $UID -ne 0 ]; then
    echo "Install failed: you must be logged in as 'root' to install."
    echo "Use command 'sudo -i', then enter root password and then try again."
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
				cp -R ~/.config/qBittorrent/* ~/qBittorrent-Backup-Linux/qBittorrent
				cp -R ~/.local/share/data/qBittorrent/BT_backup/* ~/qBittorrent-Backup-Linux/BT_backup
				zip -r -0 qBittorrent-Backup-Linux.zip qBittorrent-Backup-Linux/
				mv qBittorrent-Backup-Linux.zip ~/Downloads
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
				echo ""
				echo "-------------------------------------------------------------------------"
				echo "-------------------------------------------------------------------------"
				echo "-------------------------------------------------------------------------"
				echo "Installation Complete"
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