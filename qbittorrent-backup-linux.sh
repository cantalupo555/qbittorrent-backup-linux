#!/bin/bash

# cantalupo555/vdbhb59

# Check requirements
# "comment out with # or delete" the locate package which your OS does not need. Example PopOS (Debian) although has mlocate installed, but still needs locate to work.
if [ $UID -ne 0 ]; then
    echo -e "\n\033[1;31mRun failed. Try again using:\033[0m"
    echo "sudo ./qbittorrent-backup-linux.sh"
    exit 1
elif [ ! -f /usr/bin/zip ]; then
    echo -e "\n\033[1;31mPlease install the 'zip' package.\033[0m"
    echo "sudo apt install zip"
    exit 1
elif [ ! -f /usr/bin/unzip ]; then
    echo -e "\n\033[1;31mPlease install the 'unzip' package.\033[0m"
    echo "sudo apt install unzip"
    exit 1
elif [ ! -f /usr/bin/plocate ]; then
    echo -e "\n\033[1;31mPlease install the 'plocate' package.\033[0m"
    echo "sudo apt install plocate"
    exit 1
elif [ ! -f /usr/bin/qbittorrent ]; then
    echo -e "\n\033[1;31mqBittorrent installation not found.\033[0m"
    exit 1
fi

# Return
o1() {
    echo ""
    echo "-------------------------------------------------------------------------"
    echo "-------------------------------------------------------------------------"
    echo "-------------------------------------------------------------------------"
    echo "Press ENTER to go back!"
    echo ""
    read v
}

# Switch case
while true
do
    clear
    echo "_________________________________________________________________________"
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

            # Check config directory
            sudo updatedb
            dirCheck=$(plocate *config/qBittorrent/qBittorrent.conf)
            if [ -z $dirCheck ]; then
                echo -e "\033[1;31mqBittorrent configuration not found, launch qBittorrent client before running this script.\033[0m\n"
                exit 1
            else
                # Set user and home directory without $UID, $USER or $HOME tag
                plocate *config/qBittorrent/qBittorrent.conf > dirUser
                dir=$(cut -d"." -f1 dirUser)
                user=$(cut -d"/" -f3 dirUser)
                rm dirUser
            fi

            # Shutdown qbittorrent
            killall qbittorrent
            clear
            cont=1
            while [ $cont -ne 11 ]; do
                echo -e "\033[1;33m.-.-.-.-.-.-.-.-.-.\033[0m\n"
                sleep 1
                ((cont=$cont+1))
            done
            sleep 5

            # Create .zip structure to save the data
            cd $dir
            rm -f "$dir"qBittorrent-Backup-Linux.zip
            mkdir qBittorrent-Backup-Linux/
            mkdir qBittorrent-Backup-Linux/qBittorrent/
            mkdir qBittorrent-Backup-Linux/BT_backup/
            mkdir qBittorrent-Backup-Linux/logs/

            # Saving the data
            # Directory change after version 4.2.5
            # "LINUX: Don't create 'data' subdirectory in XDG_DATA_HOME (lbilli)"
            # https://www.qbittorrent.org/news.php
            cp -R $dir.config/qBittorrent/* qBittorrent-Backup-Linux/qBittorrent/
            if [ -d $dir.local/share/qBittorrent/ ]; then
                cp -R $dir.local/share/qBittorrent/BT_backup/* qBittorrent-Backup-Linux/BT_backup/
                cp -R $dir.local/share/qBittorrent/logs/* qBittorrent-Backup-Linux/logs/
            else
                cp -R $dir.local/share/data/qBittorrent/BT_backup/* qBittorrent-Backup-Linux/BT_backup/
                cp -R $dir.local/share/data/qBittorrent/logs/* qBittorrent-Backup-Linux/logs/
            fi

            # Last Validation
            if [ ! -f "$dir"qBittorrent-Backup-Linux/qBittorrent/qBittorrent.conf ]; then
                clear
                echo -e "\033[1;31mFailed to backup.\033[0m\n"
                rm -rf "$dir"qBittorrent-Backup-Linux/
                exit 1
            fi
            zip -r -0 qBittorrent-Backup-Linux.zip qBittorrent-Backup-Linux/
            rm -rf "$dir"qBittorrent-Backup-Linux/

            # Set permission
            chown $user:$user qBittorrent-Backup-Linux.zip
            sleep 2

            # End
            clear
            echo -e "\n\033[1;32mBackup completed.\033[0m"
            echo "Backup saved to:"
            echo -e "\e[1m$dir\e[0m""\e[1mqBittorrent-Backup-Linux.zip\e[0m"
            echo -e "\n\n\e[4mHow restore? Have this file anywhere on your system and select option 2.\e[0m"
            echo -e "\e[4mAll settings, statistics and torrent list will be restored.\e[0m"
            o1
            if [ -z "$v" ]; then
                break
            fi
            done
            ;;

        2) while true; do
            clear

            # Check config directory
            sudo updatedb
            dirCheck=$(plocate *config/qBittorrent/qBittorrent.conf)
            if [ -z $dirCheck ]; then
                echo -e "\033[1;31mqBittorrent configuration not found, launch qBittorrent client before running this script.\033[0m\n"
                exit 1
            else
                # Set user and home directory without $UID, $USER or $HOME tag
                plocate *config/qBittorrent/qBittorrent.conf > dirUser
                dir=$(cut -d"." -f1 dirUser)
                user=$(cut -d"/" -f3 dirUser)
                rm dirUser
            fi

            # Search qBittorrent-Backup-Linux.zip
            rm -f $dir.local/share/Trash/files/qBittorrent-Backup-Linux.zip
            rm -f $dir.local/share/Trash/info/qBittorrent-Backup-Linux.zip.trashinfo
            sudo updatedb
            bkp=$(plocate qBittorrent-Backup-Linux.zip)
            plocate qBittorrent-Backup-Linux.zip > zipCheck
            zipFile=$(awk 'END{print NR}' zipCheck)
            if [ $zipFile -gt 1 ]; then
                clear
                echo -e "\033[1;31mDuplicate backup file.\033[0m"
                echo -e "\033[1;31mKeep only 1 backup file in system.\033[0m\n"
                cat zipCheck
                rm zipCheck
                exit 1
            elif [ -z $bkp ]; then
                clear
                echo -e "\033[1;31mqBittorrent-Backup-Linux.zip file not found.\033[0m\n"
                rm zipCheck
                exit 1
            fi
            rm zipCheck

            # Shutdown qbittorrent
            killall qbittorrent
            clear
            cont=1
            while [ $cont -ne 11 ]; do
                echo -e "\033[1;33m.-.-.-.-.-.-.-.-.-.\033[0m\n"
                sleep 1
                ((cont=$cont+1))
            done
            sleep 10

            # Unzip file
            cd $dir
            rm -rf "$dir"qBittorrent-Backup-Linux/
            unzip $bkp
            chown -R $user:$user qBittorrent-Backup-Linux/

            # Check content
            if [ ! -f "$dir"qBittorrent-Backup-Linux/qBittorrent/qBittorrent.conf ]; then
                clear
                echo -e "\033[1;31mFailed to restore.\033[0m\n"
                rm -rf "$dir"qBittorrent-Backup-Linux/
                exit 1
            fi

            # Restoring qBittorrent
            # Directory change after version 4.2.5
            # "LINUX: Don't create 'data' subdirectory in XDG_DATA_HOME (lbilli)"
            # https://www.qbittorrent.org/news.php
            rm -rf $dir.config/qBittorrent/*
            cp -R qBittorrent-Backup-Linux/qBittorrent/* $dir.config/qBittorrent/
            chown -R $user:$user $dir.config/qBittorrent/
            if [ -d $dir.local/share/qBittorrent/ ]; then
                rm -rf $dir.local/share/qBittorrent/BT_backup/*
                cp -R qBittorrent-Backup-Linux/BT_backup/* $dir.local/share/qBittorrent/BT_backup/
                chown -R $user:$user $dir.local/share/qBittorrent/BT_backup/
                rm -rf $dir.local/share/qBittorrent/logs/*
                cp -R qBittorrent-Backup-Linux/logs/* $dir.local/share/qBittorrent/logs/
                chown -R $user:$user $dir.local/share/qBittorrent/logs/
            else
                rm -rf $dir.local/share/data/qBittorrent/BT_backup/*
                cp -R qBittorrent-Backup-Linux/BT_backup/* $dir.local/share/data/qBittorrent/BT_backup/
                chown -R $user:$user $dir.local/share/data/qBittorrent/BT_backup/
                rm -rf $dir.local/share/data/qBittorrent/logs/*
                cp -R qBittorrent-Backup-Linux/logs/* $dir.local/share/data/qBittorrent/logs/
                chown -R $user:$user $dir.local/share/data/qBittorrent/logs/
            fi

            # Clean
            rm -rf "$dir"qBittorrent-Backup-Linux/
            sleep 2

            # End
            clear
            echo -e "\n\033[1;32mRestoration completed.\033[0m"
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
