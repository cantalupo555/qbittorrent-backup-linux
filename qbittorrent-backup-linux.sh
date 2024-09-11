#!/bin/bash

# Check dependencies and user permissions
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
elif [ ! -f /usr/bin/qbittorrent ] && ( [ -z "$(which flatpak)" ] || [ -z "$(flatpak list | grep org.qbittorrent.qBittorrent)" ] ); then
    # Checks if qBittorrent is installed
    echo -e "\n\033[1;31mqBittorrent installation not found.\033[0m"
    echo "Please install qBittorrent via package manager or Flatpak."
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

detect_qbittorrent_config() {
    # Detect qBittorrent configuration directory
    echo -e "Please wait.\nDetecting configuration qBittorrent client..."
    sleep 2
    echo -e "\n\033[1;31mThis may take a few seconds.\033[0m"
    # Update the locate database to ensure the latest file locations are known
    sudo updatedb
    sleep 2

    clear
    # Search for the qBittorrent configuration directory using plocate
    # Store plocate output in array to handle multiple installations
    mapfile -t dirCheck < <(plocate *config/qBittorrent/qBittorrent.conf)
    # Check if the configuration directory was found
    if [ ${#dirCheck[@]} -eq 0 ]; then
        # If not found, display an error message and exit
        echo -e "\033[1;31mqBittorrent configuration not found, launch qBittorrent client before running this script.\033[0m\n"
        exit 1
    else
        # Handle multiple installations
        if [ ${#dirCheck[@]} -eq 1 ]; then
            # If only one installation is found, use its directory and user
            dir=$(echo "${dirCheck[0]}" | sed 's|\(/home/[^/]*\)/.*|\1/|')
            user=$(echo "$dir" | cut -d'/' -f3)
            # Check if the installation is a Flatpak
            if echo "${dirCheck[0]}" | grep -q "org.qbittorrent.qBittorrent"; then
                is_flatpak=true
                dirFlatpak=$(echo "${dirCheck[0]}" | sed 's|\(.*org\.qbittorrent\.qBittorrent\).*|\1/|')
            else
                is_flatpak=false
            fi
        else
            # Let user choose from multiple qBittorrent installations
            echo -e "\033[1;32mFound multiple qBittorrent installations:\033[0m\n"
            for i in "${!dirCheck[@]}"; do
                if echo "${dirCheck[$i]}" | grep -q "org.qbittorrent.qBittorrent"; then
                    echo -e "\033[38;5;63m$((i+1)) - [Flatpak]\033[0m ${dirCheck[$i]}"
                else
                    echo -e "\033[1;36m$((i+1)) - [Default]\033[0m ${dirCheck[$i]}"
                fi
            done
            echo -e "\033[1;31m3 - Exit\033[0m"

            # Ask the user to choose an installation
            echo -e "\n\033[1;33mWhich installation do you want to use? (Input the number: 1, 2 or 3)\033[0m"
            read -r choice

            # Handle the user's choice
            if [ "$choice" -eq 3 ]; then
                clear
                echo "You selected option 3."
                echo "Exiting..."
                exit 1
            elif [ "$choice" -le "${#dirCheck[@]}" ] && [ "$choice" -gt 0 ]; then
                selected_config="${dirCheck[$((choice-1))]}"
                # Use its directory and user based on the choice
                dir=$(echo "$selected_config" | sed 's|\(/home/[^/]*\)/.*|\1/|')
                user=$(echo "$dir" | cut -d'/' -f3)
                # Check if the installation is a Flatpak
                if echo "$selected_config" | grep -q "org.qbittorrent.qBittorrent"; then
                    is_flatpak=true
                    dirFlatpak=$(echo "$selected_config" | sed 's|\(.*org\.qbittorrent\.qBittorrent\).*|\1/|')
                else
                    is_flatpak=false
                fi
            else
                clear
                echo "Invalid choice."
                echo "You need to choose between 1 and 3."
                echo "Exiting..."
                exit 1
            fi
        fi
    fi
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

            # Call the function to detect the qBittorrent configuration directory and user
            detect_qbittorrent_config

            # View configuration details
            clear
            echo "Selected directory: $dir"
            echo "Selected user: $user"
            if [ "$is_flatpak" = true ]; then
                # If it's a Flatpak installation, display the corresponding directory
                echo -e "Flatpak directory: ${dirFlatpak}\n"
            fi
            sleep 3

            # Display a message during backup initialization
            cont=1
            while [ $cont -ne 4 ]; do
                echo -e "\033[1;33mStarting backup...\033[0m\n"
                sleep 1
                ((cont=$cont+1))
            done
            sleep 3

            # Stop the qBittorrent client to prevent conflicts during backup
            killall qbittorrent
            clear
            cont=1
            while [ $cont -ne 11 ]; do
                echo -e "\033[1;33m.-.-.-.-.-.-.-.-.-.\033[0m\n"
                sleep 1
                ((cont=$cont+1))
            done
            sleep 5

            # Create directory structure for backup
            cd $dir
            rm -f ${dir}qBittorrent-Backup-Linux.zip
            rm -rf ${dir}qBittorrent-Backup-Linux/
            mkdir qBittorrent-Backup-Linux/
            mkdir qBittorrent-Backup-Linux/qBittorrent/
            mkdir qBittorrent-Backup-Linux/BT_backup/
            mkdir qBittorrent-Backup-Linux/logs/

            # Save configuration data to backup
            # Directory change after version 4.2.5
            # "LINUX: Don't create 'data' subdirectory in XDG_DATA_HOME (lbilli)"
            # https://www.qbittorrent.org/news.php
            if [ "$is_flatpak" = true ]; then
                cp -R ${dirFlatpak}config/qBittorrent/* qBittorrent-Backup-Linux/qBittorrent/
                cp -R ${dirFlatpak}data/qBittorrent/BT_backup/* qBittorrent-Backup-Linux/BT_backup/
                cp -R ${dirFlatpak}data/qBittorrent/logs/* qBittorrent-Backup-Linux/logs/
            else
                cp -R ${dir}.config/qBittorrent/* qBittorrent-Backup-Linux/qBittorrent/
                if [ -d ${dir}.local/share/qBittorrent/ ]; then
                    cp -R ${dir}.local/share/qBittorrent/BT_backup/* qBittorrent-Backup-Linux/BT_backup/
                    cp -R ${dir}.local/share/qBittorrent/logs/* qBittorrent-Backup-Linux/logs/
                else
                    cp -R ${dir}.local/share/data/qBittorrent/BT_backup/* qBittorrent-Backup-Linux/BT_backup/
                    cp -R ${dir}.local/share/data/qBittorrent/logs/* qBittorrent-Backup-Linux/logs/
                fi
            fi

            # Checks if the configuration file was copied correctly to the backup
            if [ ! -f "$dir"qBittorrent-Backup-Linux/qBittorrent/qBittorrent.conf ]; then
                clear
                echo -e "\033[1;31mFailed to backup.\033[0m\n"
                rm -rf "$dir"qBittorrent-Backup-Linux/
                exit 1
            fi
            zip -r -0 qBittorrent-Backup-Linux.zip qBittorrent-Backup-Linux/
            rm -rf "$dir"qBittorrent-Backup-Linux/

            # Set permissions for the backup file
            chown $user:$user qBittorrent-Backup-Linux.zip
            sleep 2

            # Displays the backup completion message and restore instructions
            clear
            echo -e "\n\033[1;32mBackup completed.\033[0m\n"
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

            # Call the function to detect the qBittorrent configuration directory and user
            detect_qbittorrent_config

            # View configuration details
            clear
            echo "Selected directory: $dir"
            echo "Selected user: $user"
            if [ "$is_flatpak" = true ]; then
                # If it's a Flatpak installation, display the corresponding directory
                echo -e "Flatpak directory: ${dirFlatpak}\n"
            fi
            sleep 3

            # Display a message during restore initialization
            cont=1
            while [ $cont -ne 4 ]; do
                echo -e "\033[1;33mStarting restore...\033[0m\n"
                sleep 1
                ((cont=$cont+1))
            done
            sleep 3

            # Search for the qBittorrent-Backup-Linux.zip file
            # Remove any existing backup file in the Trash directory
            rm -f $dir.local/share/Trash/files/qBittorrent-Backup-Linux.zip
            rm -f $dir.local/share/Trash/info/qBittorrent-Backup-Linux.zip.trashinfo
            # Update the locate database to ensure the latest file locations are known
            sudo updatedb
            bkp=$(plocate qBittorrent-Backup-Linux.zip)
            plocate qBittorrent-Backup-Linux.zip > zipCheck
            # Count the number of lines in the zipCheck file to determine if there are multiple backup files
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

            # Stop the qBittorrent client to prevent conflicts during restore
            killall qbittorrent
            clear
            cont=1
            while [ $cont -ne 11 ]; do
                echo -e "\033[1;33m.-.-.-.-.-.-.-.-.-.\033[0m\n"
                sleep 1
                ((cont=$cont+1))
            done
            sleep 5

            # Unzip file
            cd $dir
            rm -rf "$dir"qBittorrent-Backup-Linux/
            unzip $bkp
            chown -R $user:$user qBittorrent-Backup-Linux/

            # Check if the backup file was extracted correctly
            if [ ! -f "$dir"qBittorrent-Backup-Linux/qBittorrent/qBittorrent.conf ]; then
                clear
                echo -e "\033[1;31mFailed to restore.\033[0m\n"
                rm -rf "$dir"qBittorrent-Backup-Linux/
                exit 1
            fi

            # Restore qBittorrent configuration and data
            # Directory change after version 4.2.5
            # "LINUX: Don't create 'data' subdirectory in XDG_DATA_HOME (lbilli)"
            # https://www.qbittorrent.org/news.php
            if [ "$is_flatpak" = true ]; then
                rm -rf ${dirFlatpak}config/qBittorrent/*
                cp -R qBittorrent-Backup-Linux/qBittorrent/* ${dirFlatpak}config/qBittorrent/
                chown -R $user:$user ${dirFlatpak}config/qBittorrent/
                rm -rf ${dirFlatpak}data/qBittorrent/BT_backup/*
                cp -R qBittorrent-Backup-Linux/BT_backup/* ${dirFlatpak}data/qBittorrent/BT_backup/
                chown -R $user:$user ${dirFlatpak}data/qBittorrent/BT_backup/
                rm -rf ${dirFlatpak}data/qBittorrent/logs/*
                cp -R qBittorrent-Backup-Linux/logs/* ${dirFlatpak}data/qBittorrent/logs/
                chown -R $user:$user ${dirFlatpak}data/qBittorrent/logs/
            else
                rm -rf ${dir}.config/qBittorrent/*
                cp -R qBittorrent-Backup-Linux/qBittorrent/* ${dir}.config/qBittorrent/
                chown -R $user:$user ${dir}.config/qBittorrent/
                if [ -d ${dir}.local/share/qBittorrent/ ]; then
                    rm -rf ${dir}.local/share/qBittorrent/BT_backup/*
                    cp -R qBittorrent-Backup-Linux/BT_backup/* ${dir}.local/share/qBittorrent/BT_backup/
                    chown -R $user:$user ${dir}.local/share/qBittorrent/BT_backup/
                    rm -rf ${dir}.local/share/qBittorrent/logs/*
                    cp -R qBittorrent-Backup-Linux/logs/* ${dir}.local/share/qBittorrent/logs/
                    chown -R $user:$user ${dir}.local/share/qBittorrent/logs/
                else
                    rm -rf ${dir}.local/share/data/qBittorrent/BT_backup/*
                    cp -R qBittorrent-Backup-Linux/BT_backup/* ${dir}.local/share/data/qBittorrent/BT_backup/
                    chown -R $user:$user ${dir}.local/share/data/qBittorrent/BT_backup/
                    rm -rf ${dir}.local/share/data/qBittorrent/logs/*
                    cp -R qBittorrent-Backup-Linux/logs/* ${dir}.local/share/data/qBittorrent/logs/
                    chown -R $user:$user ${dir}.local/share/data/qBittorrent/logs/
                fi
            fi

            # Clean up the temporary backup directory
            rm -rf "$dir"qBittorrent-Backup-Linux/
            sleep 2

            # Displays the restore completion message
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
