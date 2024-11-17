#!/bin/bash

###################################################################
# Declare vars
###################################################################
# Detect busybox
busybox_path=""

if [ -f "/data/adb/magisk/busybox" ]; then
    busybox_path="/data/adb/magisk/busybox"
elif [ -f "/data/adb/ksu/bin/busybox" ]; then
    busybox_path="/data/adb/ksu/bin/busybox"
elif [ -f "/data/adb/ap/bin/busybox" ]; then
    busybox_path="/data/adb/ap/bin/busybox"
fi
###################################################################

###################################################################
# Function to display options and respond to key presses
###################################################################
key() {
    echo "[ VOL+ ] = [ Download the Updated PIF ]"
    echo "[ VOL- ] = [ Run Troubleshooting ]"
    echo -e "\nYour selection?"

    local maxtouch=3  
    local touches=0  

    while true; do
        keys=$(getevent -lqc1)
        
        # Check for timeout
        if [ "$touches" -ge "$maxtouch" ]; then
            echo "! No Response, aborting ..."
            break
        fi

        # Detect Volume Up press
        if echo "$keys" | "$busybox_path" grep -q 'KEY_VOLUMEUP.*DOWN'; then
            
            ###################################################################
            # Read mode.txt and decide branch
            ###################################################################
            # Default to 'main' branch
            branch="main"

            if [ -f "/data/adb/modules/playcurl_NEXT/mode.txt" ]; then
                mode_value=$(cat /data/adb/modules/playcurl_NEXT/mode.txt)

                # If the value in mode.txt is "random", use the random branch
                if [ "$mode_value" = "random" ]; then
                    branch="random"
                    echo "[*] Using 'random' branch based on mode.txt"
                else
                    echo "[*] Using 'main' branch based on mode.txt"
                fi
            else
                echo "[*] mode.txt not found, using 'main' branch by default"
            fi

            ###################################################################
            # Download pif
            ###################################################################
            echo "[*] Start of the script"

            if [ -f /data/adb/modules/playintegrityfix/migrate.sh ]; then
                if [ -d /data/adb/modules/tricky_store ]; then
                    # Download osmosis.json from the selected branch
                    if /system/bin/curl -o /data/adb/modules/playintegrityfix/custom.pif.json "https://raw.githubusercontent.com/daboynb/autojson/$branch/osmosis.json" >/dev/null 2>&1; then
                        echo "[+] Successfully downloaded osmosis.json from $branch branch."
                    else
                        echo "[-] Failed to download osmosis.json from $branch branch."
                    fi
                else
                    # If tricky_store does not exist, download device_osmosis.json from the selected branch
                    if /system/bin/curl -o /data/adb/modules/playintegrityfix/custom.pif.json "https://raw.githubusercontent.com/daboynb/autojson/$branch/device_osmosis.json" >/dev/null 2>&1; then
                        echo "[+] Successfully downloaded device_osmosis.json from $branch branch."
                    else
                        echo "[-] Failed to download device_osmosis.json from $branch branch."
                    fi
                fi
            else
                # Download chiteroman.json from the selected branch
                if /system/bin/curl -L "https://raw.githubusercontent.com/daboynb/autojson/$branch/chiteroman.json" -o /data/adb/pif.json >/dev/null 2>&1; then
                    echo "[+] Successfully downloaded chiteroman.json from $branch branch."
                else
                    echo "[-] Failed to download chiteroman.json from $branch branch."
                fi
            fi

            ###################################################################
            # Check unsigned rom
            ###################################################################
            # Check the keys of /system/etc/security/otacerts.zip
            get_keys=$("$busybox_path" unzip -l /system/etc/security/otacerts.zip)

            if echo "$get_keys" | "$busybox_path" grep -q test; then

                # Check for the presence of migrate.sh and use the appropriate file path
                if [ -f /data/adb/modules/playintegrityfix/migrate.sh ]; then
                    $busybox_path sed -i 's/"spoofSignature": *0/"spoofSignature": 1/g' /data/adb/modules/playintegrityfix/custom.pif.json
                else
                    $busybox_path sed -i 's/"spoofSignature": *"false"/"spoofSignature": "true"/g' /data/adb/pif.json
                fi
            fi

            ###################################################################
            # Kill GMS processes
            ###################################################################
            killall com.google.android.gms >/dev/null 2>&1
            killall com.google.android.gms.unstable >/dev/null 2>&1

            echo "[*] End of the script"
            echo ""
            sleep 3
            
            return 0 
        # Detect Volume Down press
        elif echo "$keys" | "$busybox_path" grep -q 'KEY_VOLUMEDOWN.*DOWN'; then
            ###################################################################
            # Read mode.txt and decide branch
            ###################################################################
            # Default to 'main' branch
            branch="main"

            if [ -f "/data/adb/modules/playcurl_NEXT/mode.txt" ]; then
                mode_value=$(cat /data/adb/modules/playcurl_NEXT/mode.txt)

                # If the value in mode.txt is "random", use the random branch
                if [ "$mode_value" = "random" ]; then
                    branch="random"
                    echo "[*] Using 'random' branch based on mode.txt"
                else
                    echo "[*] Using 'main' branch based on mode.txt"
                fi
            else
                echo "[*] mode.txt not found, using 'main' branch by default"
            fi
            ###################################################################

            ###################################################################
            # Download pif
            ###################################################################
            echo "[*] Start of the script"

            if [ -f /data/adb/modules/playintegrityfix/migrate.sh ]; then
                if [ -d /data/adb/modules/tricky_store ]; then
                    # Download osmosis.json from the selected branch
                    if /system/bin/curl -o /data/adb/modules/playintegrityfix/custom.pif.json "https://raw.githubusercontent.com/daboynb/autojson/$branch/osmosis.json" >/dev/null 2>&1; then
                        echo "[+] Successfully downloaded osmosis.json from $branch branch."
                    else
                        echo "[-] Failed to download osmosis.json from $branch branch."
                    fi
                else
                    # If tricky_store does not exist, download device_osmosis.json from the selected branch
                    if /system/bin/curl -o /data/adb/modules/playintegrityfix/custom.pif.json "https://raw.githubusercontent.com/daboynb/autojson/$branch/device_osmosis.json" >/dev/null 2>&1; then
                        echo "[+] Successfully downloaded device_osmosis.json from $branch branch."
                    else
                        echo "[-] Failed to download device_osmosis.json from $branch branch."
                    fi
                fi
            else
                # Download chiteroman.json from the selected branch
                if /system/bin/curl -L "https://raw.githubusercontent.com/daboynb/autojson/$branch/chiteroman.json" -o /data/adb/pif.json >/dev/null 2>&1; then
                    echo "[+] Successfully downloaded chiteroman.json from $branch branch."
                else
                    echo "[-] Failed to download chiteroman.json from $branch branch."
                fi
            fi
            ###################################################################

            ###################################################################
            # Check unsigned rom
            ###################################################################
            # Check the keys of /system/etc/security/otacerts.zip
            get_keys=$("$busybox_path" unzip -l /system/etc/security/otacerts.zip)

            if echo "$get_keys" | "$busybox_path" grep -q test; then

                # Check for the presence of migrate.sh and use the appropriate file path
                if [ -f /data/adb/modules/playintegrityfix/migrate.sh ]; then
                    $busybox_path sed -i 's/"spoofSignature": *0/"spoofSignature": 1/g' /data/adb/modules/playintegrityfix/custom.pif.json
                else
                    $busybox_path sed -i 's/"spoofSignature": *"false"/"spoofSignature": "true"/g' /data/adb/pif.json
                fi
            fi
            ###################################################################

            ###################################################################
            # Disable other modules for testing incompatibility
            ###################################################################
            # Get a list of directories under /data/adb/modules
            list="$("$busybox_path" find /data/adb/modules/* -prune -type d)"
            for module in $list; do
                # Create a 'disable' file in each module directory
                touch "$module/disable"
            done

            # Remove the 'disable' file to enable the Play Integrity Fix module
            rm /data/adb/modules/playintegrityfix/disable > /dev/null 2>/dev/null

            # Check if busybox path is specific to Magisk
            if [ "$busybox_path" = "/data/adb/magisk/busybox" ]; then
                # Check if Zygisk is enabled in Magisk settings
                [ ! "$(magisk --sqlite "SELECT value FROM settings WHERE key='zygisk';")" == "value=0" ] && {
                    # If Zygisk is enabled, do nothing
                    :
                } || {
                    # Zygisk is disabled, remove 'disable' file to enable Zygisk SU
                    rm /data/adb/modules/zygisksu/disable > /dev/null 2>/dev/null
                }
            else
                # If busybox path is not Magisk's, remove 'disable' file to enable Zygisk SU
                rm /data/adb/modules/zygisksu/disable > /dev/null 2>/dev/null
            fi

            if [ -d /data/adb/modules/tricky_store ]; then 
                # Rename all .xml files in the directory to have a .bak extension
                for file in /data/adb/tricky_store/*.xml; do
                    if [ -f "$file" ]; then
                        mv "$file" "${file}.bak"
                    fi
                done
                
                # Download the aosp keybox
                if /system/bin/curl -o /data/adb/tricky_store/keybox.xml "https://raw.githubusercontent.com/daboynb/autojson/refs/heads/main/aosp_keybox.xml" >/dev/null 2>&1; then
                    echo "[+] Successfully downloaded the aosp keybox."
                else
                    echo "[-] Failed to download the aosp keybox."
                fi
            fi
            reboot >/dev/null 2>&1

            echo "The phone should have rebooted by itself. If you are reading this, reboot manually!"
            ###################################################################
            return 1 
        fi

        sleep 1
        touches=$((touches + 1))  
    done
}
###################################################################

# Main script execution
echo -e "\n=== Choose an option ==="
key  
echo -e "\n=== Script Ended ==="